class ExpensesController < ApplicationController

  before_action :set_organisation
  before_action :set_recent_chats
  layout "dashboard"

  def index
  end

  def show
  end

  def new
    @expense = Expense.new(organisation: @organisation, user: current_user)
  end

  def create
    @expense = @organisation.expenses.build(expense_params)
    @expense.user ||= current_user

    if @expense.save

      if @expense.images.attached? || @expense.voice_notes.attached? || @expense.pdfs.attached?

        if @expense.images.attached?
          puts "processing image"
          process_file(@expense.images[0])
        elsif @expense.voice_notes.attached?
          puts "processing voice"
          process_file(@expense.voice_notes[0])
        elsif @expense.pdfs.attached?
          puts "processing pdf"
          process_file(@expense.pdfs[0])
        end

        puts @response.content
        # source of bugs, really really needs json only response
        content = JSON.parse(@response.content)
        full_text = content["full_text"]
        title = content["title"]
        category = content["category"]
        amount = content["amount"]
        valid_deduction = content["valid_deduction"]

        puts "the fields... " , content, title, category, amount, valid_deduction

        @expense.amount = amount
        @expense.ai_data = full_text
        @expense.ai_title = title
        @expense.category = category
        @expense.valid_deduction = valid_deduction

        @expense.save
        puts "saved expense again, is now", @expense

      end

      # todo - format block for json (mobile client)
      redirect_to organisation_path(@organisation), notice: 'Expense created successfully.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def approve
  end

  def reject
  end

  private

  # mostly re-using multi modal ai setup from messages_controller
  # slightly different purpose, no message history
  # will this need a background job? -> it's slow
  # only supporting 1 upload for MVP....

  def process_file(file)
    if file.content_type == "application/pdf"
      run_extraction(document_prompt, model: "gemini-2.0-flash", with: { pdf: @expense.pdfs[0].url })
    elsif file.image?
      run_extraction(image_prompt, model: "gpt-4o", with: { image: @expense.images[0].url })
    elsif file.audio?
      temp_file = Tempfile.new(["audio", File.extname(@expense.voice_notes[0].filename.to_s)])

      URI.open(@expense.voice_notes[0].file.url) do |remote_file|
        IO.copy_stream(remote_file, temp_file)
      end

      run_extraction(audio_prompt, model: "gpt-4o-audio-preview", with: { audio: temp_file.path })
      temp_file.unlink
    end
  end

  def run_extraction(instructions, model: "gpt-4.1-nano", with: {})
    @ruby_llm_chat = RubyLLM.chat(model: model)
    @ruby_llm_chat.with_instructions(instructions)
    message_content = "Here is an expense" # if user submits custom reason, may want to include
    @response = @ruby_llm_chat.ask(message_content, with: with)
  end

  def audio_prompt
    extraction_prompt("the full text transcription of the audio")
  end

  def document_prompt
    extraction_prompt("the full text of the document")
  end

  def image_prompt
    extraction_prompt("the full text found in the image")
  end

  def extraction_prompt(format_type_line)
    # todo - valid deduction part will need more info later
    return <<-PROMPT
      You are an expert expense and deduction/tax-write off analyzer for small businesses or freelancers.
      Return a JSON object, ONLY pure JSON, do not wrap your response in markdown. these keys:
      "full_text": #{format_type_line} ;
      "title": a one sentence or less summary of the nature of the expense ;
      "category": a one or two word broad level category of the expense ;
      "amount": the amount for the expense (including decimal for cents) ;
      "valid_deduction": a boolean whether the expense likely qualifies as a valid business expense that can be deducted for tax purpsoes
    PROMPT
  end

  def set_organisation
    @organisation = current_user.organisation
  end

  def expense_params
    params.require(:expense).permit(:reason, :status, :user_id, voice_notes: [], images: [], pdfs: [])
  end

  def set_recent_chats
    @recent_chats = @organisation.chats.order(updated_at: :desc).limit(10)
  end

end
