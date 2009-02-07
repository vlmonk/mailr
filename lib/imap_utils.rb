module ImapUtils
  private 

  def load_imap_session
    return if ['error_connection'].include?(action_name)
    get_imap_session
  end

  def get_imap_session
    begin
      @mailbox = IMAPMailbox.new
      uname = (get_mail_prefs.check_external_mail == 1 ? user.email : user.local_email)
      upass = get_upass
      @mailbox.connect(uname, upass)
      load_folders
    rescue Exception => ex
#       logger.error("Exception on loggin webmail session - #{ex} - #{ex.backtrace.join("\t\n")}")
#       render :action => "error_connection"
      render :text => ex.inspect, :content_type => 'text/plain'
    end   
  end

  def close_imap_session
    return if @mailbox.nil? or not(@mailbox.connected)
    @mailbox.disconnect
    @mailbox = nil
  end

  def get_mail_prefs
    if not(@mailprefs)
      if not(@mailprefs = MailPref.find_by_customer_id(logged_customer))
        @mailprefs = MailPref.create("customer_id"=>logged_customer)
      end
    end  
    @mailprefs
  end

  def get_upass
    if CDF::CONFIG[:crypt_session_pass]
      EzCrypto::Key.decrypt_with_password(CDF::CONFIG[:encryption_password], CDF::CONFIG[:encryption_salt], session["wmp"])
    else
      # retrun it plain
      session["wmp"]
    end  
  end  

  def load_folders
    if have_to_load_folders?()
      if params["folder_name"]
        @folder_name = params["folder_name"]
      else
        @folder_name = session["folder_name"] ? session["folder_name"] : CDF::CONFIG[:mail_inbox]
      end
      session["folder_name"] = @folder_name
      @folders = @mailbox.folders if @folders.nil?
    end  
  end

  def user
    @user = Customer.find(logged_customer) if @user.nil?
    @user
  end

  def have_to_load_folders?
    return true if ['messages', 'delete', 'reply', 'forward', 'empty', 'message', 'download',
                 'filter', 'filter_add', 'view_source', 'compose', 'prefs', 'filters'].include?(action_name)
    return false
  end
end
