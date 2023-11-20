require 'google/apis/youtube_v3'

class YoutubeController < ApplicationController
  def index
    user_id = ENV["CLIENT_ID"]
    credentials = Rails.application.config.google_authorizer.get_credentials(user_id, request)
    if credentials.nil?
      redirect_to Rails.application.config.google_authorizer.get_authorization_url(login_hint: user_id, request: request), :allow_other_host => true

    else
      #original code that doesn't work
      #youtube = Google::Apis::YoutubeV3::YouTubeService.new
      #channel = youtube.list_channels('snippet', { :mine => 'mine' }, options: { authorization: credentials })
      #render({ :text => "<pre>#{JSON.pretty_generate(channel.to_h)}</pre>" })
      
      youtube = Google::Apis::YoutubeV3::YouTubeService.new
      youtube.authorization = credentials
      channel = youtube.list_channels('snippet', mine: true)
      render :html => "<pre>#{JSON.pretty_generate(channel.to_h)}</pre>".html_safe
    end
  end

  def oauth2callback
    target_url = Google::Auth::WebUserAuthorizer.handle_auth_callback_deferred(request)
    redirect_to target_url
  end
end
