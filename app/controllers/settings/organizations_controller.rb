class Settings::OrganizationsController < ApplicationController
  before_action :authorize_admin

  def show
    @organization = current_organization
  end

  def update
    @organization = current_organization

    if @organization.update(organization_params)
      redirect_to settings_organization_path, notice: 'Organization settings updated successfully.'
    else
      render :show, status: :unprocessable_entity
    end
  end

  private

  def authorize_admin
    redirect_to dashboard_path, alert: 'Access denied.' unless current_user.admin?
  end

  def organization_params
    params.require(:organization).permit(:name, :industry, :timezone)
  end
end
