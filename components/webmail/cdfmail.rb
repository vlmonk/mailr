require 'tmail'
require 'net/smtp'
require 'mail_transform'

class CDF::Mail
	include ActionMailer::Quoting
	  
  def initialize(senderTempLocation)
    @attachments = Array.new
    @sender_temp_location = senderTempLocation
    @to_contacts = Array.new
  end
    
  def customer_id() @customer_id end
  
  def customer_id=(arg) @customer_id = arg end
    
  def from() @from end
    
  def from=(arg) @from = arg end
    
  def to() @to end
    
  def to=(arg) @to = arg end
    
  def to_contacts() @to_contacts end
    
  def to_contacts=(arg) @to_contacts = arg end
    
  def toc=(arg)
    @to_contacts = Array.new
    arg.split(",").each { |token| @to_contacts << token.to_i unless token == "" or token.strip() == "undefined"} unless arg.nil? or arg == "undefined"
  end
    
  def toc
    ret = String.new
    @to_contacts.each { |contact|
      ret << "," unless ret == ""
      if contact.kind_of?(Integer)
        ret << contact.to_s unless contact.nil? or contact == 0
      else
        ret << contact.id.to_s unless contact.nil? or contact.id.nil?
      end
    }
    ret
  end
    
  def bcc() @bcc end
    
  def bcc=(arg) @bcc = arg end
    
  def cc() @cc end
    
  def cc=(arg) @cc = arg end
    
  def subject() @subject end
    
  def subject=(arg) @subject = arg end
    
  def attachments
    @attachments
  end
    
  def add_attachment(attachment)
    @attachments << attachment
  end
    
  def multipart?
    @attachments && @attachments.size > 0
  end
    
  def delete_attachment(att_filename)
    @attachments.each { |att| att.delete_temp_data() if arr.filename == att_filename }
    @attachments.delete_if() { |att| att.filename == att_filename }
  end
    
  def delete_attachments()
    @attachments.each { |att| att.delete_temp_data() }
    @attachments = Array.new
  end
    
  def body() @body end
    
  def body=(arg) @body = arg end
    
  def content_type() @content_type end
    
  def content_type=(arg) @content_type = arg end
    
  def temp_location() @sender_temp_location end
    
  def send_mail(db_msg_id = 0)
    m = TMail::Mail.new
    m.from, m.body = self.from, self.body
    m.date = Time.now
    m.subject, = quote_any_if_necessary("UTF-8", self.subject)  
    m.to = decode_addresses(self.to)
      
    m.cc, m.bcc = decode_addresses(self.cc), decode_addresses(self.bcc)
      
    if multipart?
      m.set_content_type("multipart/mixed")
      p = TMail::Mail.new(TMail::StringPort.new(""))
      if @content_type.include?("text/plain") # here maybe we should encode in 7bit??!!
        prepare_text(p, self.content_type, self.body)
      elsif self.content_type.include?("text/html")
        prepare_html(p, self.content_type, self.body)
      elsif self.content_type.include?("multipart")
        prepare_alternative(p, self.body)
      end
      m.parts << p
    else
      if @content_type.include?("text/plain") # here maybe we should encode in 7bit??!!
        prepare_text(m, self.content_type, self.body)
      elsif self.content_type.include?("text/html")
        prepare_html(m, self.content_type, self.body)
      elsif self.content_type.include?("multipart")
        prepare_alternative(m, self.body)
      end
    end
    # attachments
    @attachments.each { |a|
      m.parts << a.encoded
    }
    encmail = m.encoded
    RAILS_DEFAULT_LOGGER.debug("Sending message \n #{encmail}")
    Net::SMTP.start(ActionMailer::Base.server_settings[:address], ActionMailer::Base.server_settings[:port], 
          ActionMailer::Base.server_settings[:domain], ActionMailer::Base.server_settings[:user_name], 
          ActionMailer::Base.server_settings[:password], ActionMailer::Base.server_settings[:authentication]) do |smtp|
        smtp.sendmail(encmail, m.from, m.destinations)
    end
    return encmail
  end
    
  def forward(tmail, fb)
    decoded_subject = mime_encoded?(tmail.subject) ? mime_decode(tmail.subject) : tmail.subject
    self.subject = "[Fwd: #{decoded_subject}]"
 		attachment = CDF::Attachment.new(self)
   	attachment.body(tmail, fb)
  end
    
  def reply(tmail, fb, type)
		decoded_subject = mime_encoded?(tmail.subject) ? mime_decode(tmail.subject) : tmail.subject
    self.subject = "[Re: #{decoded_subject}]"
    tm = tmail.setup_reply(tmail)
		self.to = tm.to
		footer = ""
		msg_id = ""
		mt = MailTransform.new
    self.body = mt.get_body(tmail, type)
  end
        
  private 
  
  def delimeter
    if self.content_type == "text/plain"
      "\n"
    else
      "<br/>"
    end
  end
      
  def text2html(str) CGI.escapeHTML(str).gsub("\n", "<br/>") end
    
  def html2text(txt)
    clear_html(txt)
  end
    
  def prepare_text(msg, ctype, bdy)
    msg.set_content_type(ctype, nil, {"charset"=>"utf-8"})
    msg.transfer_encoding = "8bit"
    msg.body = bdy
  end
    
  def prepare_html(msg, ctype, bdy)
    msg.set_content_type(ctype, nil, {"charset"=>"utf8"})
    msg.transfer_encoding = "8bit"
    msg.body = bdy
  end
    
  def prepare_alternative(msg, bdy)
    bound = ::TMail.new_boundary
      
    msg.set_content_type("multipart/alternative", nil, {"charset"=>"utf8", "boundary"=>bound})
    msg.transfer_encoding = "8bit"
      
    ptext = TMail::Mail.new(TMail::StringPort.new(""))
    phtml = TMail::Mail.new(TMail::StringPort.new(""))
      
    prepare_text(ptext, "text/plain", html2text(bdy))
    prepare_html(phtml, "text/html", bdy)
      
    msg.parts << ptext
    msg.parts << phtml
  end
    
  def decode_addresses(str)
    ret = String.new
    str.split(",").each { |addr|
      if addr.slice(0,4) == "Grp+"
        grp_id = addr.scan(/Grp\+([0-9]*):(.*)/)[0][0]
        ContactGroup.find(:first, :conditions=>['customer_id = ? and id = ?', @customer_id, grp_id]).contacts.each { |contact|
          ret << "," if not(ret == "")
          @to_contacts << contact unless contact.nil?
          ret << contact.full_address
          ad, = quote_any_address_if_necessary(CDF::CONFIG[:mail_charset], contact.full_address)
          ret << ad
        }
      else
        ret << "," if not(ret == "")
        ad, = quote_any_address_if_necessary(CDF::CONFIG[:mail_charset], addr) if not(addr.nil? or addr == "")
        ret << ad if not(addr.nil? or addr == "")
      end
    } unless str.nil? or str.strip() == ""
    ret
  end
end
  
class CDF::Attachment
  
  def initialize(arg)
    @mail = arg
    @mail.add_attachment(self)
    @index = @mail.attachments.size - 1
  end
    
  def filename=(arg)
    @filename = arg.tr('\\/:*?"\'<>|', '__________')
  end
    
  def filename() @filename end
    
  def temp_filename=(arg) @temp_filename = arg end
    
  def temp_filename() @temp_filename end
    
  def content_type=(arg) @content_type = arg end
    
  def content_type() @content_type end
    
  def delete_temp_data()
    File.delete(self.temp_filename)
  end
    
  def file
    File.open(self.temp_filename, "rb") { |fp| fp.read }
  end
    
  def file=(data)
    return if data.size == 0
    @content_type = data.content_type
    self.filename = data.original_filename.scan(/[^\\]*$/).first
    self.temp_filename = "#{@mail.temp_location}/#{@filename}"
    check_store_path
    data.rewind
    File.open(@temp_filename, "wb") { |f| f.write(data.read) }
  end
  
  def body(data, fb)
    @content_type = "message/rfc822"
    filename = data.content_type['filename']
    self.filename = filename.nil? ? (mime_encoded?(data.subject) ? mime_decode(data.subject) : data.subject) : filename
    self.temp_filename = "#{@mail.temp_location}/#{@filename}"
    check_store_path
    File.open(@temp_filename, "wb") { |f| f.write(fb) }
  end
    
  def check_store_path()
    path = ""
    "#{@mail.temp_location}".split(File::SEPARATOR).each { |p|
      path << p
      begin
        Dir.mkdir(path)
      rescue
      end  
      path << File::SEPARATOR
    }  
  end
    
  def encoded
    p = TMail::Mail.new(TMail::StringPort.new(""))
    data = self.file
    p.body = data
    if @content_type.include?("text/plain") # here maybe we should encode in 7bit??!!
      p.set_content_type(@content_type, nil, {"charset"=>"utf-8"})
      p.transfer_encoding = "8bit"
    elsif @content_type.include?("text/html")
      p.set_content_type(@content_type, nil, {"charset"=>"utf8"})
      p.transfer_encoding = "8bit"
    elsif @content_type.include?("rfc822")
      p.set_content_type(@content_type, nil, {"charset"=>"utf8"})
      p.set_disposition("inline;")
      p.transfer_encoding = "8bit"
    else  
      p.set_content_type(@content_type, nil, {"name"=>@filename})
      p.set_disposition("inline; filename=#{@filename}") unless @filename.nil?
      p.set_disposition("inline;") if @filename.nil?
      p.transfer_encoding='Base64'
      p.body = TMail::Base64.folding_encode(data)
    end
    return p  
  end
end
