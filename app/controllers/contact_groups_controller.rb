class ContactGroupsController < ApplicationController
  layout 'public'
  
  def index
    @contact_group = ContactGroup.new
    @contact_group.customer_id = logged_user
    @contactgroups = ContactGroup.find_by_user(logged_user)
  end
  
  def add
    @contactgroup = ContactGroup.new
    @contactgroup.customer_id = logged_user
    render("/contact_group/edit")
  end
  
  def delete
    contactgroup = ContactGroup.find(@params["id"])
    contactgroup.destroy
    redirect_to(:action=>"list")
  end
  
  def edit
    @contactgroup = ContactGroup.find(@params["id"])
  end
  
  def save
    begin
      if @params["contactgroup"]["id"].nil? or @params["contactgroup"]["id"] == ""
        # New contactgroup
        @contactgroup = ContactGroup.create(@params["contactgroup"])
      else
        # Edit existing
        @contactgroup = ContactGroup.find(@params["contactgroup"]["id"])
        @contactgroup.attributes = @params["contactgroup"]
      end
      
      if @contactgroup.save
        redirect_to(:action=>"list")
      else
        render "/contact_group/edit"
      end
    rescue CDF::ValidationError => e
      logger.info("RESCUE")
      @contactgroup = e.entity
      render("/contact_group/edit")
    end
  end
  
  protected
  def secure_user?() true end
  
end
