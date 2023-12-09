class RecentVideosController < ApplicationController
  def index
    matching_recent_videos = RecentVideo.all

    @list_of_recent_videos = matching_recent_videos.order({ :created_at => :desc })

    render({ :template => "recent_videos/index" })
  end

  def show
    the_id = params.fetch("path_id")

    matching_recent_videos = RecentVideo.where({ :id => the_id })

    @the_recent_video = matching_recent_videos.at(0)

    render({ :template => "recent_videos/show" })
  end

  def create
    the_recent_video = RecentVideo.new
    the_recent_video.video_id = params.fetch("query_video_id")
    the_recent_video.user_id = params.fetch("query_user_id")
    the_recent_video.called_at = params.fetch("query_called_at")
    the_recent_video.not_interested = params.fetch("query_not_interested", false)
    the_recent_video.watch_later = params.fetch("query_watch_later", false)

    if the_recent_video.valid?
      the_recent_video.save
      redirect_to("/recent_videos", { :notice => "Recent video created successfully." })
    else
      redirect_to("/recent_videos", { :alert => the_recent_video.errors.full_messages.to_sentence })
    end
  end

  def update
    the_id = params.fetch("path_id")
    the_recent_video = RecentVideo.where({ :id => the_id }).at(0)

    the_recent_video.video_id = params.fetch("query_video_id")
    the_recent_video.user_id = params.fetch("query_user_id")
    the_recent_video.called_at = params.fetch("query_called_at")
    the_recent_video.not_interested = params.fetch("query_not_interested", false)
    the_recent_video.watch_later = params.fetch("query_watch_later", false)

    if the_recent_video.valid?
      the_recent_video.save
      redirect_to("/recent_videos/#{the_recent_video.id}", { :notice => "Recent video updated successfully."} )
    else
      redirect_to("/recent_videos/#{the_recent_video.id}", { :alert => the_recent_video.errors.full_messages.to_sentence })
    end
  end

  def destroy
    the_id = params.fetch("path_id")
    the_recent_video = RecentVideo.where({ :id => the_id }).at(0)

    the_recent_video.destroy

    redirect_to("/recent_videos", { :notice => "Recent video deleted successfully."} )
  end
end
