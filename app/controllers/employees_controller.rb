class EmployeesController < ApplicationController
  before_action :set_organisation
  before_action :set_recent_chats
  layout "dashboard"

  def index
    @employees = @organisation.employees
    @employee = User.new(organisation: @organisation, role: "employee")
  end

  def create
    #https://github.com/scambra/devise_invitable
    @employee = User.invite!(email: employee_params[:email]) do |user|
      user.name = employee_params[:name]
      user.role = "employee"
      user.organisation = @organisation
    end

    if @employee.errors.empty?
      redirect_to organisation_employees_path(@organisation), notice: "Invitation sent to #{@employee.email}!"
    else
      render :index, status: :unprocessable_entity
    end
  end

  def destroy
  end

  private

  def set_organisation
    @organisation = current_user.organisation
  end

  def set_recent_chats
    @recent_chats = @organisation.chats.order(updated_at: :desc).limit(10)
  end

  def employee_params
    params.require(:user).permit(:name, :email)
  end

end
