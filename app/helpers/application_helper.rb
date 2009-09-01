# The methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  include NavigationHelper
  
  protected 

  def format_datetime(datetime)
    datetime.strftime "%d.%m.%Y %H:%M"
  end

  def errors_base(form_name)
    errors = instance_variable_get("@#{form_name}").errors.on_base()
    errors_out = ""
    if errors
      errors = [errors] unless errors.is_a? Array
      errors.each do |e|
        errors_out << "<span class=\"error\">#{e}</span>"
      end
    end
    errors_out
  end

  # Useful abstraction for form input fields - combines an input field with error message (if any)
  # and writes an appropriate style (for errors)
  # Usage:
  #   form_input :text_field, 'postform', 'subject'
  #   form_input :text_area, 'postform', 'text', 'Please enter text:', 'cols' => 80
  #   form_input :hidden_field, 'postform', 'topic_id'
  def form_input(helper_method, form_name, field_name, prompt = field_name.capitalize, options = {})
    case helper_method.to_s
    when 'hidden_field'
      self.hidden_field(form_name, field_name)
    when /^.*button$/
      <<-EOL
      <tr><td class="button" colspan="2">
        #{self.send(helper_method, form_name, prompt, options)}
      </td></tr>
      EOL
    else
      field = (
        if :select == helper_method
          self.send(helper_method, form_name, field_name, options.delete('values'), options)
        elsif :collection_select == helper_method
          self.send(helper_method, form_name, field_name, options.delete('collection'), options.delete('value_method'), options.delete('text_method'), options)
        else
          self.send(helper_method, form_name, field_name, options)
        end)
      errors = instance_variable_get("@#{form_name}").errors[field_name] unless instance_variable_get("@#{form_name}").nil?
      errors = Array.new if errors.nil?
      errors_out = ""
      if errors
        errors = [errors] unless errors.is_a? Array
        errors.each do |e|
          errors_out << "<span class=\"error\">#{e}</span>"
        end
      end
      if options['class'] == 'two_columns'
        <<-EOL
        <tr class="two_columns">
          <td class="prompt"><label>#{prompt}:</label></td>
          <td class="value">#{field}#{errors_out}</td>
        </tr>
        EOL
      else
        <<-EOL
        <tr><td class="prompt"><strong>#{prompt}:</strong></td></tr>
        <tr><td class="value">#{field}#{errors_out}</td></tr>
        EOL
      end
    end
  end

  # Helper method that has the same signature as real input field helpers, but simply displays 
  # the value of a given field enclosed within <p> </p> tags.
  # Usage:
  #   <%= form_input :read_only_field, 'new_user', 'name', _('user_name')) %>
  def read_only_field(form_name, field_name, html_options)
    "<span #{attributes(html_options)}>#{instance_variable_get('@' + form_name)[field_name]}</span>"
  end

  def submit_button(form_name, prompt, html_options)
    %{<input name="submit" type="submit" value="#{prompt}" />}
  end

  # Converts a hash to XML attributes string. E.g.:
  #  to_attributes('a' => 'aaa', 'b' => 1)
  #  => 'a="aaa" b="1" '
  def attributes(hash)
    hash.keys.inject("") { |attrs, key| attrs + %{#{key}="#{hash[key]}" } }
  end
    
  def initListClass
    @itClass = 1
  end
  
  def popListClass
    ret = getListClass
    @itClass = @itClass + 1
    return ret
  end
  
  def getListClass
    return "even" if @itClass%2 == 0
    return "odd" if @itClass%2 == 1
  end
  
  def get_meta_info
    '<meta name="rating" content="General">'
    '<meta name="robots" content="Index, ALL">'
    '<meta name="description" content="">'
    '<meta name="keywords" content="">'
    '<meta name content="">'
  end
    
  def user
    @user = Customer.find(@session["user"]) if @user.nil?
    @user
  end

  def link_main 
    link_to( t(:contacts), contacts_path)
  end

  def alternator
    if @alternator.nil?
      @alternator = 1
    end
    
    @alternator = -@alternator
    
    if @alternator == -1
      return "even"
    else
      return "odd"
    end
  end

end
