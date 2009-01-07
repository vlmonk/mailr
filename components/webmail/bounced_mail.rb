class BouncedMail < ActiveRecord::Base
  belongs_to :customer
  belongs_to :contact
  
  def BouncedMail.find_by_customer_contact(cust_id, contact_id)
    find_all(["customer_id = ? and contact_id = ?", cust_id, cotact_id], ["msg_date desc"])
  end
end
