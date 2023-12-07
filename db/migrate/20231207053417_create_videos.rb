class CreateVideos < ActiveRecord::Migration[7.0]
  def change
    create_table :videos do |t|
      t.integer :youtube_channel_id
      t.string :video_url
      t.string :thumbnail_url
      t.string :title
      t.time :published_at

      t.timestamps
    end
  end
end
