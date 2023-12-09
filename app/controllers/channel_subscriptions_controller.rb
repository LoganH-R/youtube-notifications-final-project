class ChannelSubscriptionsController < ApplicationController
  def index
    matching_channel_subscriptions = ChannelSubscription.all

    @list_of_channel_subscriptions = matching_channel_subscriptions.order({ :created_at => :desc })

    render({ :template => "channel_subscriptions/index" })
  end

  def show
    the_id = params.fetch("path_id")

    matching_channel_subscriptions = ChannelSubscription.where({ :id => the_id })

    @the_channel_subscription = matching_channel_subscriptions.at(0)

    render({ :template => "channel_subscriptions/show" })
  end

  def create
    the_channel_subscription = ChannelSubscription.new
    the_channel_subscription.youtube_channel_id = params.fetch("query_youtube_channel_id")
    the_channel_subscription.user_id = params.fetch("query_user_id")
    the_channel_subscription.favorited = params.fetch("query_favorited", false)

    if the_channel_subscription.valid?
      the_channel_subscription.save
      redirect_to("/channel_subscriptions", { :notice => "Channel subscription created successfully." })
    else
      redirect_to("/channel_subscriptions", { :alert => the_channel_subscription.errors.full_messages.to_sentence })
    end
  end

  def update
    the_id = params.fetch("path_id")
    the_channel_subscription = ChannelSubscription.where({ :id => the_id }).at(0)

    the_channel_subscription.youtube_channel_id = params.fetch("query_youtube_channel_id")
    the_channel_subscription.user_id = params.fetch("query_user_id")
    the_channel_subscription.favorited = params.fetch("query_favorited", false)

    if the_channel_subscription.valid?
      the_channel_subscription.save
      redirect_to("/channel_subscriptions/#{the_channel_subscription.id}", { :notice => "Channel subscription updated successfully."} )
    else
      redirect_to("/channel_subscriptions/#{the_channel_subscription.id}", { :alert => the_channel_subscription.errors.full_messages.to_sentence })
    end
  end

  def destroy
    the_id = params.fetch("path_id")
    the_channel_subscription = ChannelSubscription.where({ :id => the_id }).at(0)

    the_channel_subscription.destroy

    redirect_to("/channel_subscriptions", { :notice => "Channel subscription deleted successfully."} )
  end
end
