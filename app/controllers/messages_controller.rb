# this was copied & adjusted from CoOwners (older state before Assistants API) & based entirely on lectures
# brainstorm / todo:
# a) RAG -> do a query from my vector DB, then send subset to GPT + user query
# b) just send expenses in initial message

class MessagesController < ApplicationController
  SYSTEM_PROMPT = "You are an expert accountant expense analyser for this organisation. You will answer queries about the state of expenses and deductions/valid tax write-offs."

  before_action :set_organisation
  before_action :set_recent_chats
  layout "dashboard"

  def create
    @chat = @organisation.chats.find(params[:chat_id])

    @message = Message.new(message_params)
    @message.chat = @chat
    @message.role = "user"

    if @message.save
      if @message.file.attached?
        process_file(@message.file)
      else
        send_question
      end

      @chat.messages.create(role: "assistant", content: @response.content)
      @chat.generate_title_from_first_message

      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to organisation_chat_path(@organisation, @chat) }
      end
    else
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace("new_message", partial: "messages/form", locals: { chat: @chat, message: @message }) }
        format.html { render "chats/show", status: :unprocessable_entity }
      end
    end
  end

  private

  def process_file(file)
    if file.content_type == "application/pdf"
      send_question(model: "gemini-2.0-flash", with: { pdf: @message.file.url })
    elsif file.image?
      send_question(model: "gpt-4o", with: { image: @message.file.url })
    elsif file.audio?
      temp_file = Tempfile.new(["audio", File.extname(@message.file.filename.to_s)])

      URI.open(@message.file.url) do |remote_file|
        IO.copy_stream(remote_file, temp_file)
      end

      send_question(model: "gpt-4o-audio-preview", with: { audio: temp_file.path })
      temp_file.unlink
    end
  end

  def send_question(model: "gpt-4.1-nano", with: {})
    @ruby_llm_chat = RubyLLM.chat(model: model)
    build_conversation_history
    @ruby_llm_chat.with_instructions(instructions)
    @response = @ruby_llm_chat.ask(@message.content, with: with)
  end

  def build_conversation_history
    @chat.messages.each do |message|
      @ruby_llm_chat.add_message({ role: message.role, content: message.content })
    end
  end

  def expenses_context
    expenses_data = []
    current_user.organisation.expenses.each do |expense|
      expenses_data.push({
        expense: expense.attributes,
        employee: expense.user.name
      })
    end
    "The expenses data is: #{expenses_data}"
  end

  def organisation_context
    "The organisation is called #{@organisation.name}."
  end

  def instructions
    # todo - only add the expenses_context the first message
    [SYSTEM_PROMPT, organisation_context, expenses_context].compact.join("\n\n")
  end

  def message_params
    params.require(:message).permit(:content, :file)
  end

  def set_organisation
    @organisation = current_user.organisation
  end

  def set_recent_chats
    @recent_chats = @organisation.chats.order(updated_at: :desc).limit(10)
  end
end
