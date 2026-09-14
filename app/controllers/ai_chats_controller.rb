# frozen_string_literal: true

class AiChatsController < ApplicationController
  before_action :require_login

  def create
    prompt = params[:prompt].to_s.strip
    return head :bad_request if prompt.blank?

    session_id = session[:ai_chat_session_id] ||= SecureRandom.uuid

    user_message = current_user.chat_messages.create!(
      role: "user",
      content: prompt,
      session_id: session_id
    )

    assistant_message = current_user.chat_messages.create!(
      role: "assistant",
      content: "...",
      session_id: session_id
    )

    GenerateAiPlaylistJob.perform_later(
      user_id: current_user.id,
      session_id: session_id,
      assistant_message_id: assistant_message.id
    )

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.append("chat_messages_list", partial: "ai_chats/message", locals: { message: user_message }),
          turbo_stream.append("chat_messages_list", partial: "ai_chats/message", locals: { message: assistant_message })
        ]
      end
      format.html { redirect_to profile_path }
    end
  end

  def destroy
    session[:ai_chat_session_id] = nil
    current_user.chat_messages.destroy_all
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace("ai_chat_container", partial: "ai_chats/chat", locals: { user: current_user })
      end
      format.html { redirect_to profile_path }
    end
  end
end
