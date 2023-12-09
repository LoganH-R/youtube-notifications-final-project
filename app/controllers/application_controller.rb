class ApplicationController < ActionController::Base
  skip_forgery_protection
  #before_action :authenticate_user!      I need to add this later to make sure users sign in before accessing any page
  #skip_before_action(:authenticate_user!, { :only => [:index] })   this is meant to go to the root url page controller so that they don't have to sign in there
end
