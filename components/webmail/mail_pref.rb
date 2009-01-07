require_association 'customer'

class MailPref < ActiveRecord::Base
  belongs_to :customer
    
  def MailPref.find_by_customer(customer_id)
    find_first(["customer_id = #{customer_id}"])
  end
end
