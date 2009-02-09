class ContactsController < ApplicationController
  layout :select_layout
  
  def index
    if params[:letter] && params[:letter].any?
      @contacts = Contact.for_customer(logged_user).letter(params[:letter]).paginate :page => params[:page],
        :per_page => CDF::CONFIG[:contacts_per_page]
    else
      @contacts = Contact.for_customer(logged_user).paginate :page => params[:page], :per_page => CDF::CONFIG[:contacts_per_page]
    end
  end
  
  def listLetter
    letters = CDF::CONFIG[:contact_letters]
    @contact_pages = Paginator.new(self, Contact.count(
      ["customer_id = %s and substr(UPPER(fname),1,1) = '%s'", logged_user, letters[params['id'].to_i]]), CDF::CONFIG[:contacts_per_page], params['page'])
    @contacts = Contact.find(:all, :conditions=>["customer_id = %s and substr(UPPER(fname),1,1) = '%s'", logged_user, letters[params['id'].to_i]], 
                             :order=>['fname'],  :limit=>CDF::CONFIG[:contacts_per_page], :offset=>@contact_pages.current.offset)
      
    if params["mode"] == "groups"
      if params["group_id"] and not params["group_id"].nil? and not params["group_id"] == ''
        @group_id = params["group_id"].to_i
        @contacts_for_group = Hash.new
        for contact in @contacts
          @contacts_for_group[contact.id] = 0 # initialize
          for gr in contact.groups
            if gr.contact_group_id.to_i == @group_id
              @contacts_for_group[contact.id] = 1 # checked
            end
          end
        end
      end
    end
    
    render :action => "list"
  end
  
  def new
    @contact = Contact.new
    @contact.customer_id = logged_user
    
    # load related lists
    loadLists
    
    # Init groups: because of checkbox
    # Set all to 0 => unchecked
    @groups = Hash.new
    @contactgroups.each {|g|
      @groups[g.id] = 0
    }
  end
  
  def add_multiple
    @contact = Contact.new
    @contact["file_type"] = "1"
  end
  
  def add_from_mail
    cstr = params['cstr']
    retmsg = params['retmsg']
    @session["return_to"] = url_for(:controller=>'/webmail/webmail',
                                    :action=>'folders',
                                    :msg_id=>retmsg)
    # parse string
    if i = cstr.index("<")
      name, email = cstr.slice(0, i), cstr.slice((i+1)..(cstr.strip().index(">")-1))
      fname = name.split().first
      lname = name.split().last if name.split().size() > 1
    else
      fname, lname, email = "", "", cstr
    end
    
    if @contact = Contact.find_by_user_email(logged_user, email)
      # load related lists
      loadLists
      
      @contact.fname, @contact.lname = fname, lname
      
      # groups = @contact.groups
      @groups = Hash.new
      @contactgroups.each {|g|
        groupSelected = false
        @contact.groups.each {|gr|
          if gr.contact_group_id.to_i == g.id.to_i
            groupSelected = true
            break
          end
        }
        if groupSelected
          @groups[g.id] = 1 # checked
        else
          @groups[g.id] = 0 # unchecked
        end
      }
    else
      @contact = Contact.new("fname"=>fname, "lname" => lname, "email" => email)
      @contact.customer_id = logged_user
      
      # load related lists
      loadLists
      
      # Init groups: because of checkbox
      # Set all to 0 => unchecked
      @groups = Hash.new
      @contactgroups.each {|g|
        @groups[g.id] = 0
      }
    end  
    render :action => "add"
  end
  
  def import_preview
    file = params["contact"]["data"]
    
    flash["errors"] = Array.new
    
    if file.size == 0
      flash["errors"] << _('You haven\'t selected file or the file is empty')
      @contact = Contact.new
      @contact["file_type"] = params["contact"]["file_type"]
      render :action => "add_multiple"
    end
    
    file_type = params["contact"]["file_type"]
    if file_type.nil? or file_type == '1'
      separator = ','
    else
      separator = /\t/
      
    end
    
    @contacts = Array.new
    emails = Array.new
    
    file.each {|line| 
      cdata = line.strip.chomp.split(separator)
      cont = Contact.new
      cont.fname = cdata[0].to_s.strip.chomp
      cont.lname = cdata[1].to_s.strip.chomp
      cont.email = cdata[2].to_s.strip.chomp
      
      # Check for duplicate emails in the file
      if emails.include?(cont.email)
        flash["errors"] << sprintf(_('Contact %'), file.lineno.to_s) + ": " + _('The e-mail duplicates the e-mail of another record!')
      else 
        emails << cont.email
      end
      
      @contacts << cont
    }
    
  end
  
  def import
    contacts_count = params["contact"].length
    contacts_to_import = params["contact"]
    @contacts = Array.new
    emails = Array.new
    
    flash["errors"] = Array.new
    
    for i in 0...contacts_count
      contact = Contact.new
      contact.customer_id = logged_user
      contact.fname = contacts_to_import[i.to_s]["fname"]
      contact.lname = contacts_to_import[i.to_s]["lname"]
      contact.email = contacts_to_import[i.to_s]["email"]
      
      begin
        # Check for duplicate emails in the submitted data
        if emails.include?(contact.email)
          flash["errors"] << sprintf(_('Contact %'), (i+1).to_s) + ": " + _('The e-mail duplicates the e-mail of another record!')
        else 
          emails << contact.email
        end
        # Check if contact is valid
        contact.valid?
      rescue CDF::ValidationError => e
        if not contact.errors.empty?
          ["fname", "lname", "email"].each do |attr|
            attr_errors = contact.errors.on(attr)
            attr_errors = [attr_errors] unless attr_errors.nil? or attr_errors.is_a? Array
            
            if not attr_errors.nil?
              attr_errors.each do |msg|
                flash["errors"] << l(:contact_addmultiple_errorforcontact, (i+1).to_s) + ": " + l(msg)
              end
            end
          end
        end
      end # rescue
      
      @contacts << contact
    end # for
    
    # If there are validation errors - display them
    if not flash["errors"].nil? and not flash["errors"].empty?
      render :action => "import_preview"
  else
    # save
      begin
        for contact in @contacts
          Contact.create(contact.attributes)
        end
        # Set message for successful import
        flash["alert"] = Array.new
        flash["alert"] << l(:contact_addmultiple_success, @contacts.length.to_s)
        keep_flash()
        redirect_to(:action=>"list")
      rescue Exception => exc
        flash["errors"] << exc
        render :action => "import_preview"
      end
  end
  end

  
  def choose
    if params["mode"] == "groups"
      save_groups
    end
    
    @tos, @ccs, @bccs = Array.new, Array.new, Array.new
    
    params["contacts_to"].each{ |id,value| @tos << Contact.find(id) if value == "1" } if params["contacts_to"]
    params["contacts_cc"].each{ |id,value| @ccs << Contact.find(id) if value == "1" } if params["contacts_cc"]
    params["contacts_bcc"].each{ |id,value| @bccs << Contact.find(id) if value == "1" } if params["contacts_bcc"]
    
    params["groups_to"].each{ |id,value| 
      ContactGroup.find(id).contacts.each {|c| @tos << c} if value == "1" } if params["groups_to"]
    params["groups_cc"].each{ |id,value| 
      ContactGroup.find(id).contacts.each {|c| @ccs << c} if value == "1" } if params["groups_cc"]
    params["groups_bcc"].each{ |id,value| 
      ContactGroup.find(id).contacts.each {|c| @bccs << c} if value == "1" } if params["groups_bcc"]
  end
  
  def save_groups
    contacts_for_group = params["contacts_for_group"]
    group_id = params["group_id"]
    contact_group = ContactGroup.find(group_id)
    
    
    contacts_for_group.each { |contact_id,value| 
      contact = Contact.find(contact_id)
      if value == "1" and not contact_group.contacts.include?(contact) 
        contact_group.contacts << contact 
      end
      if value == "0" and contact_group.contacts.include?(contact) 
        contact_group.contacts.delete(contact) 
      end
    }
    redirect_to(:action=>"list", :id=>group_id, :params=>{"mode"=>params["mode"]})
  end
  
  def edit
    @contact = Contact.find(params["id"])
    # load related lists
    loadLists
    
    # groups = @contact.groups
    @groups = Hash.new
    @contactgroups.each {|g|
      groupSelected = false
      @contact.groups.each {|gr|
        if gr.contact_group_id.to_i == g.id.to_i
          groupSelected = true
          break
        end
      }
      if groupSelected
        @groups[g.id] = 1 # checked
      else
        @groups[g.id] = 0 # unchecked
      end
    }    
    render :action => "add"
  end
  
  # Insert or update
  def create
    logger.info("BEGIN")
    if params["contact"]["id"] == ""
      # New contact
      @contact = Contact.create(params["contact"])
    else
      # Edit existing
      @contact = Contact.find(params["contact"]["id"])
      @contact.attributes = params["contact"]
    end
  
    @contactgroups = ContactGroup.find_by_user(logged_user)
    # Groups displayed
    groups = params['groups']
    tempGroups = Array.new
    tempGroups.concat(@contact.groups)
    
    @contactgroups.each { |cgroup| 
      includesCGroup = false
      tempGroups.each {|gr|
        if gr.contact_group_id.to_i == cgroup.id.to_i
        includesCGroup = true
        break
      end
      }
      if groups["#{cgroup.id}"] == "1" and not includesCGroup
        @contact.groups << cgroup
      end
    
      if groups["#{cgroup.id}"] == "0" and includesCGroup
        @contact.groups.delete(cgroup)
      end
    }
    if @contact.save
      if params["paction"] == _('Save')
        redirect_to :controller => "/contacts/contact", :action =>"list"
      else
        redirect_to :controller => "/contacts/contact", :action =>"add"
      end
    else
      loadLists
      @groups = Hash.new
      @contactgroups.each {|g|
        if @contact.groups.include?(g)
          @groups[g.id] = 1
        else
          @groups[g.id] = 0
        end      
      }
      redirect_to contacts_path
    end
  end
  
  def delete
    Contact.destroy(params['id'])
    redirect_to(:action=>'list')
  end
  
  protected
      def secure_user?() true end
      def additional_scripts() 
        add_s = ''
        if action_name == "choose"
          add_s<<'<script type="text/javascript" src="/javascripts/global.js"></script>'  
          add_s<<'<script type="text/javascript" src="/javascripts/contact_choose.js"></script>'  
        end
        add_s        
      end  
      
      def onload_function()
        if action_name == "choose"
          "javascript:respondToCaller();" 
        else
          ""
        end  
      end
  private
    def select_layout
      if params["mode"] == "choose"
        @mode = "choose"
        @contactgroups = ContactGroup.find_by_user(logged_user)
        'chooser'
      elsif params["mode"] == "groups"
        @mode = "groups"
        'public'
      else
        @mode = "normal"
        'public'
      end
    end
    
    def loadLists
      if @contactgroups.nil?
        @contactgroups = ContactGroup.find_by_user(logged_user)
      end
    end
end
