class OrganisationsController < ApplicationController

  layout :choose_layout

  # using as onboarding
  def new
    @organisation = Organisation.new(owner: current_user)
  end

  # using for dashboard
  def show
    @recent_chats = []
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

  def add_employee
  end

  def remove_employee
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

end
