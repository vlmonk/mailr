# == Pagination Helper
#
# === Action Pack pagination for Active Record collections
#
# <em>Sam Stephenson <sstephenson at gmail dot com></em>
#
# Pagination Helper aids in the process of paging large collections of Active
# Record objects. It offers macro-style automatic fetching of your model for
# multiple views, or explicit fetching for single actions. And if the magic
# isn't flexible enough for your needs, you can create your own paginators 
# with a minimal amount of code.
#
# Unlike most helpers, Pagination Helper is available to all of Action Pack:
# it helps you query your models with Action Controller and render links in
# Action View.
#
# ----
#
# === Controller examples
#
# Pagination Helper can handle as much or as little as you wish. In the
# controller, have it automatically query your model for pagination; or,
# if you prefer, create Paginator objects yourself.
#
# ==== Automatic pagination for every action in a controller
#
#   class PersonController < ApplicationController
#     helper :pagination     
#     model :person
#
#     paginate :people, :order_by => 'last_name, first_name',
#              :per_page => 20
#     
#     # ...
#   end
#
# Each action in this controller now has access to a <tt>@people</tt> instance 
# variable, which is an ordered collection of model objects for the current
# page (at most 20, sorted by last name and first name), and a 
# <tt>@person_pages</tt> Paginator instance. The current page is determined by
# the <tt>@params['page']</tt> variable.
#
# ==== Pagination for a single action
#
#   def list
#     @person_pages, @people =
#       paginate :people, :order_by => 'last_name, first_name'
#   end
#
# Like the previous example, but explicitly creates <tt>@person_pages</tt> and
# <tt>@people</tt> for a single action, and uses the default of 10 items per
# page.
#
# ==== Custom/"classic" pagination 
#
#   def list
#     @person_pages = Paginator.new self, Person.count, 10, @params['page']
#     @people = Person.find_all nil, 'last_name, first_name', 
#               @person_pages.current.to_sql
#   end
# 
# Explicitly creates the paginator from the previous example and uses 
# Paginator#to_sql to retrieve <tt>@people</tt> from the model.
#
# === View examples
#
# Paginator Helper includes various methods to help you display pagination 
# links in your views. (For information on displaying the paginated 
# collections you retrieve in the controller, see the documentation for
# ActionView::Partials#render_collection_of_partials.)
#
# ==== Using Paginator#basic_html
#
# Use the +basic_html+ method to get a simple list of pages (always including
# the first and last page) with a window around the current page. In your
# view, using one of the controller examples above,
#
#   <%= @person_pages.basic_html(self) %>
#
# will render a list of links. For a list of parameters, see the documentation
# for Page#basic_html.
#
# ==== Using a paginator partial
#
# If you need more advanced control over pagination links and need to paginate
# multiple actions and controllers, consider using a shared paginator partial.
# For instance, _why suggests this partial, which you might place in 
# <tt>app/views/partial/_paginator.rhtml</tt>:
#
#  <div class="counter">
#    Displaying <%= paginator.current.first_item %>
#    - <%= paginator.current.last_item %>
#    of <%= paginator.item_count %> &nbsp; &nbsp;
#  
#    <%= link_to(h('< Previous'), paginator.current.previous.to_link) + 
#        " | " if paginator.current.previous %>
#    <%= paginator.basic_html(self, 4) %>
#    <%= " | " + link_to(h('Next >'), paginator.current.next.to_link) if
#        paginator.current.next %>
#  </div> 
#
# Then in your views, simply call
#
#   <%= render_partial "partial/paginator", @person_pages %>
#
# wherever you want your pagination links to appear.
#
# ----
#
# ==== Thanks
#
# Thanks to the following people for their contributions to Pagination Helper:
# * Marcel Molina Jr (noradio), who provided the idea for and original
#   implementation of Paginator::Window, as well as endless mental support.
# * evl, who pointed out that Page#link_to should take and merge in a hash of
#   additional parameters.
# * why the lucky stiff, who wrote a lovely article on the original Pagination
#   Helper alongside the first implementation of Paginator#base_html, created 
#   Page#first_item and Page#last_item, and who provided inspiration for
#   revising Pagination Helper to make it more "Rails-ish."
# * xal, who saw the limitations of having only the macro-style paginate 
#   method and suggested the single-action version, and who also suggested the 
#   automatic inclusion into ActionController::Base.
# * jbd for feedback and debugging help.
# * ##rubyonrails on Freenode and the Rails mailing list.
#
module PaginationHelper
  # A hash holding options for controllers using macro-style pagination
  OPTIONS = Hash.new
  
  # The default options for pagination
  DEFAULT_OPTIONS = {
    :class_name => nil,
    :per_page   => 10,
    :parameter  => 'page',
    :conditions => nil,
    :order_by   => nil
  }
  
  def self.included(base) #:nodoc:
    super
    base.extend(ClassMethods)
  end
  
  def self.validate_options!(collection_id, options, in_action) #:nodoc:
    options.merge!(DEFAULT_OPTIONS) {|key, old, new| old}

    valid_options = [:class_name, :per_page, 
                     :parameter, :conditions, :order_by]
    valid_options << :actions unless in_action
    
    unknown_option_keys = options.keys - valid_options
    raise ActionController::ActionControllerError,
          "Unknown options: #{unknown_option_keys.join(', ')}" unless
            unknown_option_keys.empty?

    options[:singular_name] = Inflector.singularize(collection_id.to_s)
    options[:class_name]  ||= Inflector.camelize(options[:singular_name])
  end

  # Returns a paginator and a collection of Active Record model instances for
  # the paginator's current page. This is designed to be used in a single
  # action; to automatically paginate multiple actions, consider
  # ClassMethods#paginate.
  #
  # +options+ are:
  # <tt>:class_name</tt>:: the class name to use, if it can't be inferred by
  #                        singularizing the collection name.
  # <tt>:per_page</tt>::   the maximum number of items to include in a 
  #                        single page. Defaults to 10.
  # <tt>:parameter</tt>::  the CGI parameter from which the current page is 
  #                        determined. Defaults to 'page'; i.e., the current
  #                        page is specified by <tt>@params['page']</tt>.
  # <tt>:conditions</tt>:: optional conditions passed to Model.find_all.
  # <tt>:order_by</tt>::   optional order parameter passed to Model.find_all
  #                        and Model.count.
  def paginate(collection_id, options={})
    PaginationHelper.validate_options!(collection_id, options, true)
    paginator_and_collection_for(collection_id, options)
  end

  # These methods become class methods on any controller which includes
  # PaginationHelper.
  module ClassMethods
    # Creates a +before_filter+ which automatically paginates an Active Record
    # model for all actions in a controller (or certain actions if specified
    # with the <tt>:actions</tt> option).
    #
    # +options+ are the same as PaginationHelper#paginate, with the addition 
    # of:
    # <tt>:actions</tt>:: an array of actions for which the pagination is
    #                     active. Defaults to +nil+ (i.e., every action).
    def paginate(collection_id, options={})
      PaginationHelper.validate_options!(collection_id, options, false)
      module_eval do
        before_filter :create_paginators_and_retrieve_collections
        OPTIONS[self] ||= Hash.new
        OPTIONS[self][collection_id] = options
      end
    end
  end

  def create_paginators_and_retrieve_collections #:nodoc:
    PaginationHelper::OPTIONS[self.class].each do |collection_id, options|
      next unless options[:actions].include? action_name if options[:actions]

      paginator, collection = 
        paginator_and_collection_for(collection_id, options)

      paginator_name = "@#{options[:singular_name]}_pages"
      self.instance_variable_set(paginator_name, paginator)

      collection_name = "@#{collection_id.to_s}"
      self.instance_variable_set(collection_name, collection)     
    end
  end
  
  # Returns the total number of items in the collection to be paginated for
  # the +model+ and given +conditions+. Override this method to implement a
  # custom counter.
  def count_collection_for_pagination(model, conditions)
    model.count(conditions)
  end
  
  # Returns a collection of items for the given +model+ and +conditions+,
  # ordered by +order_by+, for the current page in the given +paginator+.
  # Override this method to implement a custom finder.
  def find_collection_for_pagination(model, conditions, order_by, paginator)
    model.find_all(conditions, order_by, paginator.current.to_sql)
  end
  
  protected :create_paginators_and_retrieve_collections,
            :count_collection_for_pagination, :find_collection_for_pagination

  def paginator_and_collection_for(collection_id, options) #:nodoc:
    klass = eval options[:class_name]
    page  = @params[options[:parameter]]
    count = count_collection_for_pagination(klass, options[:conditions])

    paginator = Paginator.new(self, count, 
      options[:per_page], page, options[:parameter])
      
    collection = find_collection_for_pagination(klass, 
      options[:conditions], options[:order_by], paginator)
      
    return paginator, collection
  end
  
  private :paginator_and_collection_for
  
  # A class representing a paginator for an Active Record collection.
  class Paginator
    include Enumerable

    # Creates a new Paginator on the given +controller+ for a set of items of
    # size +item_count+ and having +items_per_page+ items per page. Raises
    # ArgumentError if items_per_page is out of bounds (i.e., less than or 
    # equal to zero). The page CGI parameter for links defaults to "page" and
    # can be overridden with +page_parameter+.
    def initialize(controller, item_count, items_per_page, current_page=1,
                   page_parameter='page')
      raise ArgumentError, 'must have at least one item per page' if
        items_per_page <= 0

      @controller = controller
      @item_count = item_count || 0
      @items_per_page = items_per_page
      @page_parameter = page_parameter

      self.current_page = current_page
    end
    attr_reader :controller, :item_count, :items_per_page, :page_parameter

    # Sets the current page number of this paginator. If +page+ is a Page
    # object, its +number+ attribute is used as the value; if the page does 
    # not belong to this Paginator, an ArgumentError is raised.
    def current_page=(page)
      if page.is_a? Page
        raise ArgumentError, 'Page/Paginator mismatch' unless
          page.paginator == self
      end
      page = page.to_i
      @current_page = has_page_number?(page) ? page : 1
    end

    # Returns a Page object representing this paginator's current page.
    def current_page
      self[@current_page]
    end
    alias current :current_page

    # Returns a new Page representing the first page in this paginator.
    def first_page
      self[1]
    end
    alias first :first_page

    # Returns a new Page representing the last page in this paginator.
    def last_page
      self[page_count] 
    end
    alias last :last_page

    # Returns the number of pages in this paginator.
    def page_count
      return 1 if @item_count.zero?
      (@item_count / @items_per_page.to_f).ceil
    end
    alias length :page_count

    # Returns true if this paginator contains the page of index +number+.
    def has_page_number?(number)
      return false unless number.is_a? Fixnum
      number >= 1 and number <= page_count
    end

    # Returns a new Page representing the page with the given index +number+.
    def [](number)
      Page.new(self, number)
    end

    # Successively yields all the paginator's pages to the given block.
    def each(&block)
      page_count.times do |n|
        yield self[n+1]
      end
    end
  
    # Creates a basic HTML link bar for the given +view+. The first and last
    # pages of the paginator are always shown, along with +window_size+ pages
    # around the current page. By default, the current page is displayed, but
    # not linked; to change this behavior, pass true to the 
    # +link_to_current_page+ argument. Specify additional link_to parameters
    # with +params+.
    def basic_html(view, window_size=2, link_to_current_page=false, params={})
      window_pages = current.window(window_size).pages
      return if window_pages.length <= 1 unless link_to_current_page
      
      html = ''
      unless window_pages[0].first?
        html << view.link_to(first.number, first.to_link(params))
        html << ' ... ' if window_pages[0].number - first.number > 1
        html << ' '
      end

      window_pages.each do |page|
        if current == page and not link_to_current_page
          html << page.number.to_s
        else
          html << view.link_to(page.number, page.to_link(params))
        end
        html << ' '
      end

      unless window_pages.last.last?
        html << ' ... ' if last.number - window_pages[-1].number > 1
        html << view.link_to(last.number, last.to_link(params))
      end
      
      html
    end

    # A class representing a single page in a paginator.
    class Page
      include Comparable

      # Creates a new Page for the given +paginator+ with the index +number+.  
      # If +number+ is not in the range of valid page numbers or is not a 
      # number at all, it defaults to 1.
      def initialize(paginator, number)
        @paginator = paginator
        @number = number.to_i
        @number = 1 unless @paginator.has_page_number? @number
      end
      attr_reader :paginator, :number
      alias to_i :number

      # Compares two Page objects and returns true when they represent the 
      # same page (i.e., their paginators are the same and they have the same
      # page number).
      def ==(page)
        @paginator == page.paginator and 
          @number == page.number
      end

      # Compares two Page objects and returns -1 if the left-hand page comes
      # before the right-hand page, 0 if the pages are equal, and 1 if the
      # left-hand page comes after the right-hand page. Raises ArgumentError
      # if the pages do not belong to the same Paginator object.
      def <=>(page)
        raise ArgumentError unless @paginator == page.paginator
        @number <=> page.number
      end

      # Returns the item offset for the first item in this page.
      def offset
        @paginator.items_per_page * (@number - 1)
      end
      
      # Returns the number of the first item displayed.
      def first_item
        offset + 1
      end
      
      # Returns the number of the last item displayed.
      def last_item
        [@paginator.items_per_page * @number, @paginator.item_count].min
      end

      # Returns true if this page is the first page in the paginator.
      def first?
        self == @paginator.first
      end

      # Returns true if this page is the last page in the paginator.
      def last?
        self == @paginator.last
      end

      # Returns a new Page object representing the page just before this page,
      # or nil if this is the first page.
      def previous
        if first? then nil else Page.new(@paginator, @number - 1) end
      end

      # Returns a new Page object representing the page just after this page,
      # or nil if this is the last page.
      def next
        if last? then nil else Page.new(@paginator, @number + 1) end
      end

      # Returns a new Window object for this page with the specified 
      # +padding+.
      def window(padding=2)
        Window.new(self, padding)
      end

      # Returns a hash appropriate for using with link_to or url_for. Takes an
      # optional +params+ hash for specifying additional link parameters.
      def to_link(params={})
        {:params => {@paginator.page_parameter => @number.to_s}.merge(params)}
      end

      # Returns the SQL "LIMIT ... OFFSET" clause for this page.
      def to_sql
        ['? OFFSET ?', @paginator.items_per_page, offset]
      end
    end

    # A class for representing ranges around a given page.
    class Window
      # Creates a new Window object for the given +page+ with the specified
      # +padding+.
      def initialize(page, padding=2)
        @paginator = page.paginator
        @page = page
        self.padding = padding
      end
      attr_reader :paginator, :page

      # Sets the window's padding (the number of pages on either side of the
      # window page).
      def padding=(padding)
        @padding = padding < 0 ? 0 : padding
        # Find the beginning and end pages of the window
        @first = @paginator.has_page_number?(@page.number - @padding) ?
          @paginator[@page.number - @padding] : @paginator.first
        @last =  @paginator.has_page_number?(@page.number + @padding) ?
          @paginator[@page.number + @padding] : @paginator.last
      end
      attr_reader :padding, :first, :last

      # Returns an array of Page objects in the current window.
      def pages
        (@first.number..@last.number).to_a.map {|n| @paginator[n]}
      end
      alias to_a :pages
    end
  end
end

module ActionController #:nodoc:
  class Base #:nodoc:
    # Automatically include PaginationHelper.
    include PaginationHelper
  end
end
