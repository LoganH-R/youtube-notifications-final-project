Rails.application.routes.draw do
  # Routes for the Channel resource:

  # CREATE
  post("/insert_channel", { :controller => "channels", :action => "create" })
          
  # READ
  get("/channels", { :controller => "channels", :action => "index" })
  
  get("/channels/:path_id", { :controller => "channels", :action => "show" })
  
  # UPDATE
  
  post("/modify_channel/:path_id", { :controller => "channels", :action => "update" })
  
  # DELETE
  get("/delete_channel/:path_id", { :controller => "channels", :action => "destroy" })

  #------------------------------

  devise_for :users
  get("/authenticate", { :controller => "youtube", :action => "index" })
  get("/oauth2callback", { :controller => "youtube", :action => "oauth2callback" })
  
  
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root "youtube#index"
end
