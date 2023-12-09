class VideosController < ApplicationController
  def index
    matching_videos = Video.all

    @list_of_videos = matching_videos.order({ :created_at => :desc })

    render({ :template => "videos/index" })
  end

  def show
    the_id = params.fetch("path_id")

    matching_videos = Video.where({ :id => the_id })

    @the_video = matching_videos.at(0)

    render({ :template => "videos/show" })
  end

  def create
    the_video = Video.new
    the_video.youtube_channel_id = params.fetch("query_youtube_channel_id")
    the_video.video_url = params.fetch("query_video_url")
    the_video.thumbnail_url = params.fetch("query_thumbnail_url")
    the_video.title = params.fetch("query_title")
    the_video.published_at = params.fetch("query_published_at")

    if the_video.valid?
      the_video.save
      redirect_to("/videos", { :notice => "Video created successfully." })
    else
      redirect_to("/videos", { :alert => the_video.errors.full_messages.to_sentence })
    end
  end

  def update
    the_id = params.fetch("path_id")
    the_video = Video.where({ :id => the_id }).at(0)

    the_video.youtube_channel_id = params.fetch("query_youtube_channel_id")
    the_video.video_url = params.fetch("query_video_url")
    the_video.thumbnail_url = params.fetch("query_thumbnail_url")
    the_video.title = params.fetch("query_title")
    the_video.published_at = params.fetch("query_published_at")

    if the_video.valid?
      the_video.save
      redirect_to("/videos/#{the_video.id}", { :notice => "Video updated successfully."} )
    else
      redirect_to("/videos/#{the_video.id}", { :alert => the_video.errors.full_messages.to_sentence })
    end
  end

  def destroy
    the_id = params.fetch("path_id")
    the_video = Video.where({ :id => the_id }).at(0)

    the_video.destroy

    redirect_to("/videos", { :notice => "Video deleted successfully."} )
  end
end
