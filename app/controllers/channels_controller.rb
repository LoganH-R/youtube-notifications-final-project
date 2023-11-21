class ChannelsController < ApplicationController
  def index
    matching_channels = Channel.all

    @list_of_channels = matching_channels.order({ :created_at => :desc })

    render({ :template => "channels/index" })
  end

  def show
    the_id = params.fetch("path_id")

    matching_channels = Channel.where({ :id => the_id })

    @the_channel = matching_channels.at(0)

    render({ :template => "channels/show" })
  end

  def create
    the_channel = Channel.new
    the_channel.channel_name = params.fetch("query_channel_name")
    the_channel.channel_url = params.fetch("query_channel_url")
    the_channel.youtube_api_channel_id = params.fetch("query_youtube_api_channel_id")
    the_channel.channel_pfp_url = params.fetch("query_channel_pfp_url")

    if the_channel.valid?
      the_channel.save
      redirect_to("/channels", { :notice => "Channel created successfully." })
    else
      redirect_to("/channels", { :alert => the_channel.errors.full_messages.to_sentence })
    end
  end

  def update
    the_id = params.fetch("path_id")
    the_channel = Channel.where({ :id => the_id }).at(0)

    the_channel.channel_name = params.fetch("query_channel_name")
    the_channel.channel_url = params.fetch("query_channel_url")
    the_channel.youtube_api_channel_id = params.fetch("query_youtube_api_channel_id")
    the_channel.channel_pfp_url = params.fetch("query_channel_pfp_url")

    if the_channel.valid?
      the_channel.save
      redirect_to("/channels/#{the_channel.id}", { :notice => "Channel updated successfully."} )
    else
      redirect_to("/channels/#{the_channel.id}", { :alert => the_channel.errors.full_messages.to_sentence })
    end
  end

  def destroy
    the_id = params.fetch("path_id")
    the_channel = Channel.where({ :id => the_id }).at(0)

    the_channel.destroy

    redirect_to("/channels", { :notice => "Channel deleted successfully."} )
  end
end
