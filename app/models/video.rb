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
#  youtube_channel_id :integer
#
class Video < ApplicationRecord
end
