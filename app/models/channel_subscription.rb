# == Schema Information
#
# Table name: channel_subscriptions
#
#  id                 :integer          not null, primary key
#  favorited          :boolean
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  user_id            :integer
#  youtube_channel_id :integer
#
class ChannelSubscription < ApplicationRecord
  #direct associations
  belongs_to :user, required: true, class_name: "User", foreign_key: "user_id"
  belongs_to :channel, required: true, class_name: "Channel", foreign_key: "youtube_channel_id"
end
