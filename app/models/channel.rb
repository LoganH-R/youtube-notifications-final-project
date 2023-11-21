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
end
