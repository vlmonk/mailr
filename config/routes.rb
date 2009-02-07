ActionController::Routing::Routes.draw do |map|
  map.resources :folders, :requirements => {:id => /[^\/]+/}

  # Add your own custom routes here.
  # The priority is based upon order of creation: first created -> highest priority.
  
  # Here's a sample route:
  # map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action
  map.connect '', :controller=>'webmail', :action=>'index'

  map.connect 'webmail', :controller=>'webmail', :action=>'index'

  map.connect 'webmail/:action', :controller=>'webmail'
  
  map.connect '/contact/:action', :controller=>'contact'
  
  map.connect 'admin/main', :controller=> 'login', :action=>'logout'
  # Allow downloading Web Service WSDL as a file with an extension
  # instead of a file named 'wsdl'
  map.connect ':controller/service.wsdl', :action => 'wsdl'
  
  # Install the default route as the lowest priority.
  map.connect ':controller/:action/:id'
end
