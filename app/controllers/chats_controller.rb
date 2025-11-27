# this was copied & adjusted from CoOwners (older state before Assistants API) & based entirely on lectures

class ChatsController < ApplicationController
  before_action :set_organisation
  before_action :set_recent_chats
  layout "dashboard"

  def show
    @chat    = current_user.organisation.chats.find(params[:id])
    @message = Message.new
  end

  def create
    @chat = Chat.new(title: Chat::DEFAULT_TITLE)
    @chat.organisation = @organisation
    if @chat.save
      redirect_to organisation_chat_path(@organisation, @chat)
    else
      render :show
    end
  end

  def destroy
    @chat = @organisation.chats.find(params[:id])
    @chat.destroy
    redirect_to organisation_path(@organisation)
  end

  private

  def set_organisation
    @organisation = current_user.organisation
  end

  def set_recent_chats
    @recent_chats = @organisation.chats.order(updated_at: :desc).limit(10)
  end

end
