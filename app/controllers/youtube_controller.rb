require 'google/apis/youtube_v3'

class YoutubeController < ApplicationController
  before_action :authenticate_user!

  def index
    user_id = current_user.id.to_s
    credentials = Rails.application.config.google_authorizer.get_credentials(user_id, request)
    if credentials.nil?
      redirect_to Rails.application.config.google_authorizer.get_authorization_url(login_hint: user_id, request: request), :allow_other_host => true
    else
      youtube = Google::Apis::YoutubeV3::YouTubeService.new
      youtube.authorization = credentials
      channels = youtube.list_subscriptions('snippet', mine: true)
      @subscribed_channels = channels.items.map{ |subscription| subscription.snippet.resource_id.channel_id }
      #render :html => "<pre>#{JSON.pretty_generate(subscribed_channels_usernames.to_h)}</pre>".html_safe
      
      @subscribed_channels.each do |channel_id|
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

        #checking if channel_subscriptions already has an entry for that user and their subscribed channel
        if exists == true
          matching_subscribed_channels = ChannelSubscription.where({ :youtube_channel_id => repeat_channel.id }).where({ :user_id => current_user.id })
          subscription_exists = matching_subscribed_channels.count > 0

          if subscription_exists == false
            new_channel_subscription = ChannelSubscription.new
            new_channel_subscription.user_id = current_user.id
            new_channel_subscription.youtube_channel_id = repeat_channel.id

            new_channel_subscription.save
          end #if subscription does exist for that user, then you just don't add it to the subscribed channels table
        else  #if the channel doesn't exist in the database, then there is no need to check if anyone is subscribed to it because it won't exist at all
          new_channel_subscription = ChannelSubscription.new
          new_channel_subscription.user_id = current_user.id
          new_channel_subscription.youtube_channel_id = new_channel.id

          new_channel_subscription.save
        end
        #favorited column of ChannelSubscription is currently blank
      end

      render({ :template => "youtubes/index"})
    end
  end

  def oauth2callback
    target_url = Google::Auth::WebUserAuthorizer.handle_auth_callback_deferred(request)
    redirect_to target_url
  end

  def recent_videos
    #After they click on the "See Recent Videos" button, the button has the form of "/see_videos" which links to this method
    #I want to take all of the channels stored as the favorited channels, then find their most recent videos
    #for now, just do all of the channels and display just the URL
    #temporarily doing this for "subscribed channels". replace with "favorited channels" later on

    user_id = current_user.id.to_s
    credentials = Rails.application.config.google_authorizer.get_credentials(user_id, request)

    if credentials.nil?
      redirect_to Rails.application.config.google_authorizer.get_authorization_url(login_hint: user_id, request: request), :allow_other_host => true
    else
      youtube = Google::Apis::YoutubeV3::YouTubeService.new
      youtube.authorization = credentials

      subscribed_channels = ChannelSubscription.where({ :user_id => current_user.id })
      youtube_api_channel_ids = Array.new

      subscribed_channels.each do |subscribed_channel|
        database_channel_id = subscribed_channel.youtube_channel_id
        channel_id = Channel.find_by({ :id => database_channel_id }).youtube_api_channel_id
        youtube_api_channel_ids.push(channel_id)
      end

      @outputs = Array.new

      youtube_api_channel_ids.each do |youtube_api_channel_id|
        channel = youtube.list_channels('contentDetails', id: youtube_api_channel_id).items.first
        uploads_playlist_id = channel.content_details.related_playlists.uploads 

        playlist_items = youtube.list_playlist_items('snippet', playlist_id: uploads_playlist_id, max_results: 1)
        require 'time'

        if playlist_items.items.any?
          most_recent_video = playlist_items.items.first

          new_video = Video.new
          new_video.published_at = Time.parse(most_recent_video.snippet.published_at)
          api_video_id = most_recent_video.snippet.resource_id.video_id
          new_video.api_video_id = api_video_id
          new_video.video_url = "https://www.youtube.com/watch?v=#{api_video_id}"
          new_video.title = most_recent_video.snippet.title
          new_video.thumbnail_url = most_recent_video.snippet.thumbnails.default.url
          #new_video.youtube_channel_id = 

          #here i need to do the same as i did above with the checking if the video exists and adding it to the videos table, then also adding to recent videos

          @outputs.push(video_title)
        else
          @outputs.push("No videos found for this channel")
        end
      end
      
      render({ :template => "youtubes/recent_videos"})
    end

  end

end
