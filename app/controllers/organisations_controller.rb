class OrganisationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_recent_chats, except: [:new, :create]
  layout :choose_layout

  # using as onboarding
  def new
    @organisation = Organisation.new(owner: current_user)
  end

  def show
    @organisation = current_user.organisation
    @recent_chats = set_recent_chats

    expenses_scope = @organisation.expenses.order(created_at: :desc)

    if params[:status].present?
      expenses_scope = expenses_scope.where(status: params[:status])
    end
    if params[:employee].present?
      expenses_scope = expenses_scope.where(user_id: params[:employee])
    end

    @expenses = expenses_scope
    @deductions = expenses_scope.where(valid_deduction: true, status: 'approved')
    @payouts = expenses_scope.where(status: 'approved', has_reimbursed: false)
  end

  def create
    params_with_owner =  organisation_params.merge(owner: current_user)
    @organisation = Organisation.new(params_with_owner)
    if @organisation.save
      # better update the user too
      current_user.update(organisation: @organisation)
      redirect_to dashboard_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def choose_layout
    if action_name == "new"
      "onboarding"
    elsif action_name == "show"
      "dashboard"
    end
  end

  def organisation_params
    params.require(:organisation).permit(:name)
  end

  def set_recent_chats
    @recent_chats = current_user.organisation.chats.order(updated_at: :desc).limit(10)
  end

end
