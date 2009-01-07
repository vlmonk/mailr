MIME_ENCODED = /=\?([a-z\-0-9]*)\?[QB]\?([a-zA-Z0-9+\/=\_\-]+)\?=/i
IMAP_EMAIL_ENVELOPE_FORMAT = /([a-zA-Z\-\.\_]*@[a-zA-Z\-\.\_]*)/
IMAP_EMAIL_ENVELOPE_FORMAT2 = /(.*)<([a-zA-Z\-\.\_]*@[a-zA-Z\-\.\_]*)>/

require 'iconv'

def valid_email?(email)
  email.size < 100 && email =~ /.@.+\../ && email.count('@') == 1
end

def mime_encoded?( str )
  return false if str.nil? 
  not (MIME_ENCODED =~ str).nil?
end

def from_qp(str, remove_underscore = true)
  return '' if str.nil? 
  result = str.gsub(/=\r\n/, "")
  result = result.gsub(/_/, " ") if remove_underscore
  result.gsub!(/\r\n/m, $/)
  result.gsub!(/=([\da-fA-F]{2})/) { $1.hex.chr }
  result
end
  
def mime_decode(str, remove_underscore = true)
  return '' if str.nil? 
  str.gsub(MIME_ENCODED) {|s| 
    enc = s.scan(MIME_ENCODED).flatten
    if /\?Q\?/i =~ s
      begin
        Iconv.conv("UTF-8", enc[0], from_qp(enc[1], remove_underscore))
      rescue
        from_qp(enc[1], remove_underscore)
      end  
    else
      begin 
        Iconv.conv("UTF-8", enc[0], enc[1].unpack("m*").to_s)
      rescue
        enc[1].unpack("m*").to_s
      end  
    end 
  }
end

def imap2friendlly_email(str)
  begin
    if str === IMAP_EMAIL_ENVELOPE_FORMAT
      email = str.scan(IMAP_EMAIL_ENVELOPE_FORMAT)[0][0] 
    else
      email = str.scan(IMAP_EMAIL_ENVELOPE_FORMAT2)[0][0] 
    end 
    name = str.slice(0, str.rindex(email)-1)
    name = decode(name).to_s if mime_encoded?(name)
    return "#{name.nil? ? '' : name.strip}<#{email}>"
  rescue
    "Error parsing str - #{str.scan(IMAP_EMAIL_ENVELOPE_FORMAT)} - #{str.scan(IMAP_EMAIL_ENVELOPE_FORMAT2)}"
  end   
end

def imap2friendlly_name(str)
  begin
    email = str.scan(IMAP_EMAIL_ENVELOPE_FORMAT)[0][0]
    name = str.slice(0, str.rindex(email))
    if name.nil? or name.strip == ""
      return email
    else
      return name
    end
  rescue
    str
  end   
end

def imap2friendlly_full_name(str)
  begin
    email = str.scan(IMAP_EMAIL_ENVELOPE_FORMAT)[0][0]
    name = str.slice(0, str.rindex(email))
    if name.nil? or name.strip == ""
      return email
    else
      return "#{name}<#{email}>"
    end
  rescue
    str
  end   
end

def imap2name_only(str)
  email = str.scan(IMAP_EMAIL_ENVELOPE_FORMAT)[0][0]
  name = str.slice(0, str.rindex(email))
  return "#{name.nil? ? '' : name.strip}"
end

def imap2time(str)
  begin
    vals = str.scan(/(...), (.?.) (...) (....) (..):(..):(..) (.*)/)[0]
    Time.local(vals[3],vals[2],vals[1],vals[4],vals[5],vals[6])
  rescue
    Time.now
  end
end

def encode_email(names, email)
  nameen = ""
  names.each_byte { | ch | nameen = nameen +"=" + sprintf("%X",ch) }
  return "=?#{CDF::CONFIG[:mail_charset]}?Q?#{nameen}?= <#{email}>"
end

# #############################
# HTML utils
# #############################
def replace_tag(tag, attrs)
  replacements = {"body" => "",
                  "/body" => "",
                  "meta" => "",
                  "/meta" => "",
                  "head" => "",
                  "/head" => "",
                  "html" => "",
                  "/html" => "",
                  "title" => "<div class='notviscode'>",
                  "/title" => "</div>",
                  "div" => "",
                  "/div" => "",
                  "span" => "",
                  "/span" => "",
                  "layer" => "",
                  "/layer" => "",
                  "br" => "<br/>",
                  "/br" => "<br/>",
                  "iframe" => "",
                  "/iframe" => "",
                  "link" => "<xlink" << replace_attr(attrs) << ">",
                  "/link" => "</xlink" << replace_attr(attrs) << ">",
                  "style" =>  "<div class='notviscode'>",
                  "/style" =>  "</div>",
                  "script" =>  "<div class='notviscode'>",
                  "/script" =>  "</div>" }
  replacements.fetch(tag.downcase, ("<" << tag.downcase << replace_attr(attrs) << ">"))
end

def replace_attr(attrs)
  if attrs
    attrs.downcase.gsub("onload", "onfilter").
                  gsub("onclick", "onfilter").
                  gsub("onkeypress", "onfilter").
                  gsub("javascript", "_javascript").
                  gsub("JavaScript", "_javascript")
  else
    ""
  end                  
end

def clear_html(text)
  attribute_key = /[\w:_-]+/
  attribute_value = /(?:[A-Za-z0-9\-_#\%\.,\/\:]+|(?:'[^']*?'|"[^"]*?"))/
  attribute = /(?:#{attribute_key}(?:\s*=\s*#{attribute_value})?)/
  attributes = /(?:#{attribute}(?:\s+#{attribute})*)/
  tag_key = attribute_key
  tag = %r{<([!/?\[]?(?:#{tag_key}|--))((?:\s+#{attributes})?\s*(?:[!/?\]]+|--)?)>}
  text.gsub(tag, '').gsub(/\s+/, ' ').strip
  CGI::escape(text)
end

def strip_html(text)
  attribute_key = /[\w:_-]+/
  attribute_value = /(?:[A-Za-z0-9\-_#\%\.,\/\:]+|(?:'[^']*?'|"[^"]*?"))/
  attribute = /(?:#{attribute_key}(?:\s*=\s*#{attribute_value})?)/
  attributes = /(?:#{attribute}(?:\s+#{attribute})*)/
  tag_key = attribute_key
  tag = %r{<([!/?\[]?(?:#{tag_key}|--))((?:\s+#{attributes})?\s*(?:[!/?\]]+|--)?)>}
  res = text.gsub(tag) { |match|
    ret = ""
    match.scan(tag) { |token| 
      ret << replace_tag(token[0], token[1])
    }
    ret
  }
  # remove doctype tags
  xattributes = /(?:#{attribute_value}(?:\s+#{attribute_value})*)/
  xtag = %r{<!#{tag_key}((?:\s+#{xattributes})?\s*(?:[!/?\]]+|--)?)>}
  res.gsub(xtag, '')
end
