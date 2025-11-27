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
    @expense.user = current_user

    # todo - format block for json (mobile client)

    if @expense.save
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

  def set_organisation
    @organisation = current_user.organisation
  end

  def expense_params
    params.require(:expense).permit(:reason, :status, voices: [], images: [], pdfs: [])
  end

  def set_recent_chats
    @recent_chats = @organisation.chats.order(updated_at: :desc).limit(10)
  end

end
