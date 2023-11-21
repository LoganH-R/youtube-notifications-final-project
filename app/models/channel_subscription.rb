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
end
