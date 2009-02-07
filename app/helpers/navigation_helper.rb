module NavigationHelper
  def link_back_to_messages
    link_to("&#171;" << _('Back to messages'), :controller=>"webmail", :action=>"messages")
  end

  def link_send_mail
    link_to(_('Compose'), :controller=>"webmail", :action=>"compose")
  end

  def link_mail_prefs
    link_to(_('Preferences'), :controller=>"webmail", :action=>"prefs")
  end

  def link_mail_filters
    link_to(_('Filters'), :controller=>"webmail", :action=>"filters")
  end

  def folder_manage_link(folder)
    if folder.name == CDF::CONFIG[:mail_trash] or folder.name == CDF::CONFIG[:mail_inbox] or folder.name == CDF::CONFIG[:mail_sent]
      short_fn(folder)
    else
      return short_fn(folder) +
      ("&nbsp;" + link_to(_('(Delete)'), :controller=>"webmail", :action=>"manage_folders", :params=>{"op"=>_('(Delete)'), "folder_name"=>folder.name}))
    end  
  end

  def short_fn(folder)
    if folder.name.include? folder.delim
      "&nbsp; &nbsp;" + folder.name.split(folder.delim).last
    else
      folder.name
    end
  end
end
