require 'cdfutils'
require_association 'contact_group'

class Contact < ActiveRecord::Base
  
  has_and_belongs_to_many :groups, :class_name => "ContactGroup", :join_table => "contact_contact_groups", :association_foreign_key => "contact_group_id", :foreign_key => "contact_id"
  
  # Finder methods follow
  def Contact.find_by_user(user_id)
    find(:all, :conditions => ["customer_id = ?", user_id], :order => "fname asc", :limit => 10)
  end
  
  def Contact.find_by_user_email(user_id, email)
    find(:first, :conditions => ["customer_id = #{user_id} and email = ?", email])
  end
  
  def Contact.find_by_group_user(user_id, grp_id)
    result = Array.new
    find(:all, :conditions => ["customer_id = ?", user_id], :order => "fname asc").each { |c|
      begin  
        c.groups.find(grp_id)
        result << c 
      rescue ActiveRecord::RecordNotFound
      end
    }
    result
  end
  
  def Contact.find_by_user_letter(user_id, letter)
    find_by_sql("select * from contacts where customer_id=#{user_id} and substr(UPPER(fname),1,1) = '#{letter}' order by fname")
  end

  def full_name
    "#{fname}&nbsp;#{lname}"
  end
  
  def show_name
    "#{fname} #{lname}"
  end
  
  def full_address
    "#{fname} #{lname}<#{email}>"
  end
  
  protected
    def validate
      errors.add 'fname', _('Please enter your first name (2 to 20 characters).') unless self.fname =~ /^.{2,20}$/i
      errors.add 'lname', _('Please enter your surname (2 to 20 characters).') unless self.lname =~ /^.{2,20}$/i
      
      # Contact e-mail cannot be changed
      unless self.new_record?
        old_record = Contact.find(self.id)
        errors.add 'email', _('Contacts email cannot be changed.') unless old_record.email == self.email
      end
    end
    
    def validate_on_create
      # Contact e-mail cannot be changed, so we only need to validate it on create
      errors.add 'email', _('Please enter a valid email address.') unless valid_email?(self.email)
      # Already existing e-mail in contacts for this user is not allowed
      if self.new_record?
        if Contact.find :first, :conditions => {:email => email, :customer_id => customer_id}
          errors.add('email', _('An account for your email address already exists.'))
        end
      end
    end
  
end
