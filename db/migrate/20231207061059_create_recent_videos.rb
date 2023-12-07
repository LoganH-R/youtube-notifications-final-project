class CreateRecentVideos < ActiveRecord::Migration[7.0]
  def change
    create_table :recent_videos do |t|
      t.integer :video_id
      t.integer :user_id
      t.time :called_at
      t.boolean :not_interested
      t.boolean :watch_later

      t.timestamps
    end
  end
end
