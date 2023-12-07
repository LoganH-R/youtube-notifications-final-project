Rails.application.routes.draw do
  # Routes for the Channel subscription resource:

  # CREATE
  post("/insert_channel_subscription", { :controller => "channel_subscriptions", :action => "create" })
          
  # READ
  get("/channel_subscriptions", { :controller => "channel_subscriptions", :action => "index" })
  
  get("/channel_subscriptions/:path_id", { :controller => "channel_subscriptions", :action => "show" })
  
  # UPDATE
  
  post("/modify_channel_subscription/:path_id", { :controller => "channel_subscriptions", :action => "update" })
  
  # DELETE
  get("/delete_channel_subscription/:path_id", { :controller => "channel_subscriptions", :action => "destroy" })

  #------------------------------

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

  #click see recent videos button, takes you here
  get("/see_videos", { :controller => "youtube", :action => "recent_videos" })


end
