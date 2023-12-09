# == Schema Information
#
# Table name: videos
#
#  id                 :integer          not null, primary key
#  published_at       :time
#  thumbnail_url      :string
#  title              :string
#  video_url          :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  api_video_id       :string
#  youtube_channel_id :integer
#
class Video < ApplicationRecord
  belongs_to :youtube_channel, required: true, class_name: "Channel", foreign_key: "youtube_channel_id"
  has_many  :recent_videos, class_name: "RecentVideo", foreign_key: "video_id", dependent: :destroy

  has_many :user_feeds, through: :recent_videos, source: :user
  has_one  :subscriber, through: :youtube_channel, source: :subscribers

  

end
