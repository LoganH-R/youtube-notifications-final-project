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
      #---------------------------------------------
      #original code that doesn't work
      #youtube = Google::Apis::YoutubeV3::YouTubeService.new
      #channel = youtube.list_channels('snippet', { :mine => 'mine' }, options: { authorization: credentials })
      #render({ :text => "<pre>#{JSON.pretty_generate(channel.to_h)}</pre>" })
      #---------------------------------------------

      

      #--------------------------------------------------------------------
      #subscribed_channels as an Array
      #subscribed_channels_usernames = Array.new

      #subscribed_channels.each do |channel_id|
      #  response = youtube.list_channels('snippet', id: channel_id)
      #  channel = response.items.first
      #  username = channel.snippet.title
      #  subscribed_channels_usernames.push(username)
      #end
      #---------------------------------------------------------------------------

      #---------------------------------------------------------------------------
      # I want this to turn into a nested hash with each channel_id => a hash with the channel username and image source url for their profile picture
      #actually nevermind 

      #subscribed_channels_info = Hash.new
      #num_channels = 1

      #subscribed_channels.each do |channel_id|
      #  response = youtube.list_channels('snippet', id: channel_id)
      #  channel = response.items.first

      #  channel_info = {
      #    :channel_id => channel_id,
      #    :channel_title => channel.snippet.title,
      #    :channel_pfp => channel.snippet.thumbnails.default.url,
      #    :channel_url => "https://www.youtube.com/channel/#{channel_id}"
      #  }

      #  subscribed_channels_info.store("channel_#{num_channels}".to_sym, channel_info)
      #  num_channels = num_channels + 1
      #end
      #-------------------------------------------------------------------------------------
    end
  end

  def oauth2callback
    target_url = Google::Auth::WebUserAuthorizer.handle_auth_callback_deferred(request)
    redirect_to target_url
  end
end





#---------------------------------------------------------------------------------
#def favorited   #change this name to the page with the notifications
  




  #the below is temporarily 
  #this will be the nested hash for the favorited channels that will need to go into the favorited channels view template

#  favorited_channels_info = Hash.new
#  num_fav_channels = 1

#  subscribed_channels.each do |channel_id|
#    response = youtube.list_channels('snippet', id: channel_id)
#    channel = response.items.first

#    channel_info = {
#      :channel_id => channel_id,
#      :channel_title => channel.snippet.title,
#      :channel_pfp => channel.snippet.thumbnails.default.url,
#      :channel_url => "https://www.youtube.com/channel/#{channel_id}"
#    }

#    subscribed_channels_info.store("channel_#{num_channels}".to_sym, channel_info)
#    num_channels = num_channels + 1
#  end




#end
#-------------------------------------------------------------------------------
