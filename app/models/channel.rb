# == Schema Information
#
# Table name: channels
#
#  id                     :integer          not null, primary key
#  channel_name           :string
#  channel_pfp_url        :string
#  channel_url            :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  youtube_api_channel_id :string
#
class Channel < ApplicationRecord
  #I need to change these so that it doesn't say channel before everything. just have it be name, pfp_url, url
  
  #direct associations
  has_many  :videos, class_name: "Video", foreign_key: "youtube_channel_id", dependent: :destroy
  has_many  :channels_subscribed_tos, class_name: "ChannelSubscription", foreign_key: "youtube_channel_id", dependent: :destroy

  #indirect associations
  has_many :subscribers, through: :channels_subscribed_tos, source: :user
end
