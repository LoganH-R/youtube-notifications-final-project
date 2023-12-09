class AddVideoIdtoVideos < ActiveRecord::Migration[7.0]
  def change
    add_column(:videos, :api_video_id, :date)
  end
end
