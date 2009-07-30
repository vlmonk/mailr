require 'maildropserializator'
Customer.class_eval do
  include MaildropSerializator
  has_many :filters, :order => "order_num", :dependent => true
end