Rails.application.routes.draw do
  devise_for :users
  get("/authenticate", { :controller => "youtube", :action => "index" })
  get("/oauth2callback", { :controller => "youtube", :action => "oauth2callback" })
  
  
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root "youtube#index"
end
