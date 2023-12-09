class CreateChannels < ActiveRecord::Migration[7.0]
  def change
    create_table :channels do |t|
      t.string :channel_name
      t.string :channel_url
      t.string :youtube_api_channel_id
      t.string :channel_pfp_url

      t.timestamps
    end
  end
end
