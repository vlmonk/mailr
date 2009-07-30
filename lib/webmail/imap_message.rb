require 'mail2screen'
class ImapMessage < ActiveRecord::Base
 include Mail2Screen
	
 def set_folder(folder)
   @folder = folder
 end

 def full_body
   @folder.mailbox.imap.uid_fetch(uid, "BODY[]").first.attr["BODY[]"]
 end
 
 def from_addr=(fa)
   self.from = fa.to_yaml
   self.from_flat = short_address(fa)
 end
 
 def from_addr
   begin
     YAML::load(from)
   rescue Object
     from
   end
 end
 
 def to_addr=(ta)
   self.to = ta.to_yaml
   self.to_flat = short_address(ta)
 end
 
 def to_addr
   begin
     YAML::load(to)
   rescue Object
     to
   end
 end
end