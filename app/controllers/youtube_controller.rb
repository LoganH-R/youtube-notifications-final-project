require 'google/apis/youtube_v3'

class YoutubeController < ApplicationController
  def index
    user_id = current_user.id
    credentials = Rails.application.config.google_authorizer.get_credentials(user_id, request)
    if credentials.nil?
      redirect_to Rails.application.config.google_authorizer.get_authorization_url(login_hint: user_id, request: request), :allow_other_host => true
    else
      youtube = Google::Apis::YoutubeV3::YouTubeService.new
      youtube.authorization = credentials
      channels = youtube.list_subscriptions('snippet', mine: true)
      subscribed_channels = channels.items.map{ |subscription| subscription.snippet.resource_id.channel_id }
      #render :html => "<pre>#{JSON.pretty_generate(subscribed_channels_usernames.to_h)}</pre>".html_safe
      
      subscribed_channels.each do |channel_id|
        response = youtube.list_channels('snippet', id: channel_id)
        channel = response.items.first

        matching_channels = Channel.where({ :youtube_api_channel_id => channel_id })
        exists = matching_channels.count > 0

        if exists == true
          repeat_channel = matching_channels.first

          if repeat_channel.channel_name != channel.snippet.title
            repeat_channel.channel_name = channel.snippet.title
            repeat_channel.save
          end

          if repeat_channel.channel_pfp_url != channel.snippet.thumbnails.default.url
            repeat_channel.channel_pfp_url = channel.snippet.thumbnails.default.url
            repeat_channel.save
          end
        else
          new_channel = Channel.new
          new_channel.youtube_api_channel_id = channel_id
          new_channel.channel_name = channel.snippet.title
          new_channel.channel_pfp_url = channel.snippet.thumbnails.default.url
          new_channel.channel_url = "https://www.youtube.com/channel/#{channel_id}"
          new_channel.save
        end

        new_channel_subscription = ChannelSubscription.new
        new_channel_subscription.user_id = current_user.id
        if exists == true
          new_channel_subscription.youtube_channel_id = repeat_channel.id
        else
          new_channel_subscription.youtube_channel_id = new_channel.id
        end
        #did not include anything about favorited column
        new_channel_subscription.save
      end
    end

    render({ :template => "youtubes/index"})
  end

  def oauth2callback
    target_url = Google::Auth::WebUserAuthorizer.handle_auth_callback_deferred(request)
    redirect_to target_url
  end
end
