# == Schema Information
#
# Table name: recent_videos
#
#  id             :integer          not null, primary key
#  called_at      :time
#  not_interested :boolean
#  watch_later    :boolean
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  user_id        :integer
#  video_id       :integer
#
class RecentVideo < ApplicationRecord
  #i may want to change the name of video_id to instead be youtube_video_id to distinguish it from the api video_id but its fine for now
  #direct_associations
  belongs_to :user, required: true, class_name: "User", foreign_key: "user_id"
  belongs_to :video, required: true, class_name: "Video", foreign_key: "video_id"
end
