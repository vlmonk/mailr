require 'ezcrypto'
class LoginController < ApplicationController
  
  def index
    if not(logged_user.nil?)
      redirect_to :controller =>"webmail", :action=>"index" 
    else
      @login_user = Customer.new
    end 
  end
  
  def authenticate
    if user = auth(params['login_user']["email"], params['login_user']["password"])
      session["user"] = user.id
      if CDF::CONFIG[:crypt_session_pass]
        session["wmp"] = EzCrypto::Key.encrypt_with_password(CDF::CONFIG[:encryption_password], CDF::CONFIG[:encryption_salt], params['login_user']["password"])
      else
        # dont use crypt
        session["wmp"] = params['login_user']["password"]
      end  
      if session["return_to"]
        redirect_to_path(session["return_to"])
        session["return_to"] = nil
      else
        redirect_to :action=>"index" 
      end
    else
      @login_user = Customer.new
      flash["error"] = _('Wrong email or password specified.')
      redirect_to :action => "index" 
    end
  end
  
  def logout
    reset_session
    flash["status"] = _('User successfully logged out')
    redirect_to :action => "index" 
  end
  
  protected

  def need_subdomain?() true end
  def secure_user?() false end

  private

  def auth(email, password)
    mailbox = IMAPMailbox.new
    begin
      mailbox.connect(email, password)
    rescue
      return nil
    end
    mailbox.disconnect
    mailbox = nil
    if user = Customer.find_by_email(email)
      return user
    else
      # create record in database
      user = Customer.create("email"=>email)
      MailPref.create('customer_id' => user.id)
      return user
    end 
  end    
end
