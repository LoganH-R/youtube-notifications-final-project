# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#
class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  
  #direct associations
  has_many :channels_subscribed_tos, class_name: "ChannelSubscription", foreign_key: "user_id", dependent: :destroy
  has_many  :recent_videos, class_name: "RecentVideo", foreign_key: "user_id", dependent: :destroy

  #indirect associations
  has_many :channels_subscribed_to, through: :channels_subscribed_tos, source: :channel
  has_many :recent_video_feed, through: :recent_videos, source: :video
  has_many :videos, through: :channels_subscribed_to, source: :videos
  
end
