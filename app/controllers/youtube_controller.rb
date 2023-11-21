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
      channels = youtube.list_subscriptions('snippet', mine: true)
      subscribed_channels = channels.items.map{ |subscription| subscription.snippet.resource_id.channel_id }

      subscribed_channels_usernames = Array.new

      subscribed_channels.each do |channel_id|
        response = youtube.list_channels('snippet', id: channel_id)
        channel = response.items.first
        username = channel.snippet.title
        subscribed_channels_usernames.push(username)
      end

      

      render :html => "<pre>#{JSON.pretty_generate(subscribed_channels_usernames.to_h)}</pre>".html_safe
    end
  end

  def oauth2callback
    target_url = Google::Auth::WebUserAuthorizer.handle_auth_callback_deferred(request)
    redirect_to target_url
  end
end
