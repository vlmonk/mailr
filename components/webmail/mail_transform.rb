require 'mail2screen'

class MailTransform
  include Mail2Screen
  
  def get_body(tmail, type)
    @mail = tmail
    footer = ""
    msg_id = ""
    ret = mail2html(tmail, msg_id)
    ret = ret.gsub(/<br\/>/,"\n").gsub(/&nbsp;/, " ").gsub(/&lt;/, "<").gsub(/&gt;/, ">").gsub(/&amp;/, "&").gsub(/<hr\/>/, "\n").gsub(/\n/, "\n> ") if type == 'text/plain'
    ret = ret.gsub(/\r\n/,"<br/>").gsub(/\r/, "<br/>").gsub(/\n/,"<br/>").gsub(/<br\/>/, "<br/>&gt;&nbsp;") unless type == 'text/plain'
    return ret
  end
  
  def mail2html(mail, msg_id)
    footer = ""
    parsed_body = create_body(mail, msg_id, footer)
    
    ret = "-----Original Message-----\n#{_('From')}:#{address(mail.from_addrs, @msg_id)}\n"
    ret << "#{_('To')}:#{address(mail.to_addrs, @msg_id)}\n"
    if @mail.cc_addrs
      ret << "  #{_('CC')}:#{address(mail.cc_addrs, @msg_id)}\n"
    end
    if @mail.bcc_addrs
      ret << "#{_('BCC')}:#{address(mail.bcc_addrs, @msg_id)}\n"
    end
    ret << "#{_('Subject')}:#{mime_encoded?(mail.subject) ? mime_decode(mail.subject) : mail.subject}\n"  
    ret << "#{_('Date')}:#{message_date(mail.date)}\n"
    ret << "\n"
    ret << "\n"
    ret << parsed_body
    ret << "\n"
  end
  
  def message_date(datestr)
    t = Time.now
    begin
      if datestr.kind_of?(String)
        d = (Time.rfc2822(datestr) rescue Time.parse(value)).localtime
      else
        d = datestr
      end
      if d.day == t.day and d.month == t.month and d.year == t.year
        d.strftime("%H:%M")
      else
        d.strftime("%Y-%m-%d")
      end  
    rescue
      begin
        d = imap2time(datestr)
        if d.day == t.day and d.month == t.month and d.year == t.year
          d.strftime("%H:%M")
        else
          d.strftime("%Y-%m-%d")
        end  
      rescue
        datestr
      end
    end
  end
  
  # Overwrite some staff
  def add_to_contact(addr, msg_id)
    ""
  end
  def add_attachment(content_type, msg_id)
    ""
  end
  
  def add_image(content_type, msg_id)
    ""
  end
  
end