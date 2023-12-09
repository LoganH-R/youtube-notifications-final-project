require "google/apis/youtube_v3"

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
      channels = youtube.list_subscriptions("snippet", mine: true)
      @subscribed_channels = channels.items.map { |subscription| subscription.snippet.resource_id.channel_id }
      #render :html => "<pre>#{JSON.pretty_generate(subscribed_channels_usernames.to_h)}</pre>".html_safe

      @subscribed_channels.each do |channel_id|
        response = youtube.list_channels("snippet", id: channel_id)
        channel = response.items.first

        matching_channels = Channel.where({ :youtube_api_channel_id => channel_id })
        exists = matching_channels.count > 0

        #test
        #@pfp = channel.snippet.thumbnails.high.url
        #i can do .high, .medium, .default. what changes here in the url is the "s###" part towards the end of the url. it can either be s800, s240, or s88, being high, medium, or default, respectively.

        #checking resolution of thumbnail image
        pfps = channel.snippet.thumbnails
        if pfps.high.url == nil
          if pfps.medium.url == nil
            pfp_url = pfps.default.url
          else
            pfp_url = pfps.medium.url
          end
        else
          pfp_url = pfps.high.url
        end
        
        if exists == true
          repeat_channel = matching_channels.first

          if repeat_channel.channel_name != channel.snippet.title
            repeat_channel.channel_name = channel.snippet.title
            repeat_channel.save
          end

          if repeat_channel.channel_pfp_url != pfp_url
            repeat_channel.channel_pfp_url = pfp_url
            repeat_channel.save
          end
        else
          new_channel = Channel.new
          new_channel.youtube_api_channel_id = channel_id
          new_channel.channel_name = channel.snippet.title
          new_channel.channel_pfp_url = pfp_url
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
        else #if the channel doesn't exist in the database, then there is no need to check if anyone is subscribed to it because it won't exist at all
          new_channel_subscription = ChannelSubscription.new
          new_channel_subscription.user_id = current_user.id
          new_channel_subscription.youtube_channel_id = new_channel.id

          new_channel_subscription.save
        end
        #favorited column of ChannelSubscription is currently blank
      end

      render({ :template => "youtubes/index" })
    end
  end

  def oauth2callback
    target_url = Google::Auth::WebUserAuthorizer.handle_auth_callback_deferred(request)
    redirect_to target_url
  end

  def recent_videos
    #After they click on the "See Recent Videos" button, the button has the form of "/see_videos" which links to this method
    #I want to take all of the channels stored as the favorited channels, then find their most recent videos
    
    user_id = current_user.id.to_s
    credentials = Rails.application.config.google_authorizer.get_credentials(user_id, request)

    if credentials.nil?
      redirect_to Rails.application.config.google_authorizer.get_authorization_url(login_hint: user_id, request: request), :allow_other_host => true
    else
      youtube = Google::Apis::YoutubeV3::YouTubeService.new
      youtube.authorization = credentials

      if request.post?
        favorited_channels_api_ids = Array.new
        favorited_channels_api_ids = params["favorited_channels"]

        #set favorited status for all channels not included here as false. accounts for if a user updated something
        all_channels_subscribed_to = ChannelSubscription.where({ :user_id => current_user.id })
        all_channels_subscribed_to.each do |a_channel_subscribed_to|
          the_database_channel_subscribed_to = Channel.find_by({ :id => a_channel_subscribed_to.youtube_channel_id })
          favorited_or_not = favorited_channels_api_ids.include?(the_database_channel_subscribed_to.youtube_api_channel_id)
          if favorited_or_not == false
            a_channel_subscribed_to.favorited = false
            a_channel_subscribed_to.save
          end
        end
      elsif request.get?
        favorited_channels = Array.new
        favorited_channels = ChannelSubscription.where({ :user_id => current_user.id }).where({ :favorited => true })
        favorited_channels_api_ids = Array.new
        favorited_channels.each do |a_favorited_channel|
          the_favorited_channel = Channel.where({ :id => a_favorited_channel.youtube_channel_id }).first
          api_id_of_favorited_channel = the_favorited_channel.youtube_api_channel_id
          favorited_channels_api_ids.push(api_id_of_favorited_channel)
        end
      end

      @favorited_channels_recent_videos = Array.new

      favorited_channels_api_ids.each do |favorited_channel_api_id|
        #add favorited status to subscribed channel
        database_channel = Channel.find_by({ :youtube_api_channel_id => favorited_channel_api_id })
        matching_subscribed_channel = ChannelSubscription.where({ :user_id => current_user.id }).where({ :youtube_channel_id => database_channel.id })
        subscribed_channel = matching_subscribed_channel.first
        subscribed_channel.favorited = true
        subscribed_channel.save
        
        #accessing channel's recent video. I might have the error where if a channel doesn't have any videos it might result in an error
        channel = youtube.list_channels("contentDetails", id: favorited_channel_api_id).items.first
        uploads_playlist_id = channel.content_details.related_playlists.uploads

        playlist_items = youtube.list_playlist_items("snippet", playlist_id: uploads_playlist_id, max_results: 1)
        require "time"

        if playlist_items.items.any?
          most_recent_video = playlist_items.items.first
          api_video_id = most_recent_video.snippet.resource_id.video_id

          matching_channel = Channel.where({ :youtube_api_channel_id => favorited_channel_api_id }).first
          
          matching_videos = Video.where({ :api_video_id => api_video_id })
          exists = matching_videos.count > 0

          #test
          #@thumbnail = most_recent_video.snippet.thumbnails.standard.url
          #i can do .maxres, .high, .standard, .default
          
          #checking resolution of thumbnail image
          thumbnails = most_recent_video.snippet.thumbnails
          if thumbnails.maxres.url == nil
            if thumbnails.standard.url == nil
              if thumbnails.high.url == nil
                if thumbnails.medium.url == nil
                  most_recent_video_thumbnail_url = thumbnails.default.url
                else
                  most_recent_video_thumbnail_url = thumbnails.medium.url
                end
              else
                most_recent_video_thumbnail_url = thumbnails.high.url
              end
            else
              most_recent_video_thumbnail_url = thumbnails.standard.url
            end
          else
            most_recent_video_thumbnail_url = thumbnails.maxres.url
          end

          if exists == true
            repeat_video = matching_videos.first

            if repeat_video.published_at != Time.parse(most_recent_video.snippet.published_at)
              repeat_video.published_at = Time.parse(most_recent_video.snippet.published_at)
              repeat_video.save
            end

            if repeat_video.video_url != "https://www.youtube.com/watch?v=#{api_video_id}"
              repeat_video.video_url = "https://www.youtube.com/watch?v=#{api_video_id}"
              repeat_video.save
            end

            if repeat_video.title != most_recent_video.snippet.title
              repeat_video.title = most_recent_video.snippet.title
              repeat_video.save
            end

            if repeat_video.thumbnail_url != most_recent_video_thumbnail_url
              repeat_video.thumbnail_url = most_recent_video_thumbnail_url
              repeat_video.save
            end

            if repeat_video.youtube_channel_id != matching_channel.id
              repeat_video.youtube_channel_id = matching_channel.id
              repeat_video.save
            end

            @favorited_channels_recent_videos.push(repeat_video)
          else
            new_video = Video.new
            new_video.published_at = Time.parse(most_recent_video.snippet.published_at)
            new_video.api_video_id = api_video_id
            new_video.video_url = "https://www.youtube.com/watch?v=#{api_video_id}"
            new_video.title = most_recent_video.snippet.title
            new_video.thumbnail_url = most_recent_video_thumbnail_url
            new_video.youtube_channel_id = matching_channel.id

            new_video.save

            @favorited_channels_recent_videos.push(new_video)
          end

          #checking if recent_videos already has an entry for that user and their recent videos page
          if exists == true
            matching_recent_videos = RecentVideo.where({ :video_id => repeat_video.id }).where({ :user_id => current_user.id })
            recent_video_exists = matching_recent_videos.count > 0

            if recent_video_exists == false
              new_recent_video = RecentVideo.new
              new_recent_video.user_id = current_user.id
              new_recent_video.video_id = repeat_video.id

              new_recent_video.save
            end #if recent video does exist for that user, then you just don't add it to the recent videos table
          else #if the video doesn't exist in the database, then there is no need to check if anyone has it as their recent video because it won't exist at all
            new_recent_video = RecentVideo.new
            new_recent_video.user_id = current_user.id
            new_recent_video.video_id = new_video.id

            new_recent_video.save
          end
          #called_at, not_interested, and watch_later are not addressed yet

        end
      end

      render({ :template => "youtubes/see_recent_videos" })
    end
  end
end
