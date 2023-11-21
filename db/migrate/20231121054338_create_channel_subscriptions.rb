class CreateChannelSubscriptions < ActiveRecord::Migration[7.0]
  def change
    create_table :channel_subscriptions do |t|
      t.integer :youtube_channel_id
      t.integer :user_id
      t.boolean :favorited

      t.timestamps
    end
  end
end
