class OrganisationsController < ApplicationController

  layout :choose_layout

  # can be onboarding
  def new
  end

  # can be dashboard
  def show
  end

  def create
  end

  # I can manage emplyoees from this controller (devise User controllers maybe harder)
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

end
