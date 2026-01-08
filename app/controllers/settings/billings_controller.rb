class Settings::BillingsController < ApplicationController
  before_action :authorize_owner

  def show
    @organization = current_organization
    @subscription = @organization.subscription
    @plan = @subscription&.plan
  end

  private

  def authorize_owner
    redirect_to dashboard_path, alert: 'Access denied.' unless current_user.owner?
  end
end
