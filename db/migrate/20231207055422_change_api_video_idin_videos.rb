class ChangeApiVideoIdinVideos < ActiveRecord::Migration[7.0]
  def change
    change_column(:videos, :api_video_id, :string)
  end
end
