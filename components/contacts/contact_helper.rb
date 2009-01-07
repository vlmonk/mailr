module Contacts::ContactHelper
  def link_import_preview() "/contacts/contact/import_preview" end
  def link_main_index() "/webmail/webmail/folders" end
  def link_contact_save() "/contacts/contact/save" end
  def link_contact_import() "/contacts/contact/import" end
  def link_contact_choose() "/contacts/contact/choose" end

  def link_contact_list
    link_to(_('List'), :controller => "/contacts/contact", :action => "list") 
  end

  def link_contact_add_one
    link_to(_('Add one contact'), :controller => "/contacts/contact", :action => "add") 
  end

  def link_contact_add_multiple
    link_to(_('Add multiple'), :controller => "/contacts/contact", :action => "add_multiple") 
  end
  
  def link_contact_group_list 
    link_to(_('Groups'), :controller => "/contacts/contact_group", :action => "list") 
  end

  def link_folders
    link_to(_('Folders'), :controller=>"/webmail/webmail", :action=>"messages")
  end
  
  def link_send_mail
    link_to(_('Compose'), :controller=>"/webmail/webmail", :action=>"compose")
  end

  def link_mail_prefs
    link_to(_('Preferences'), :controller=>"/webmail/webmail", :action=>"prefs")
  end
  
  def link_mail_filters
    link_to(_('Filters'), :controller=>"/webmail/webmail", :action=>"filters")
  end

end
