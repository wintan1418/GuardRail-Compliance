class ApplicationController < ActionController::Base
  include Pundit::Authorization

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :authenticate_user!
  before_action :set_current_context
  before_action :configure_permitted_parameters, if: :devise_controller?

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  protected

  def set_current_context
    return unless user_signed_in?

    Current.user = current_user
    Current.organization = current_user.organization
    Current.ip_address = request.remote_ip
    Current.user_agent = request.user_agent
    Current.request_id = request.request_id
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [
      :first_name, :last_name, :phone, :organization_name, :industry
    ])
    devise_parameter_sanitizer.permit(:account_update, keys: [
      :first_name, :last_name, :phone, :title, :license_number, :license_expiration,
      :email_notifications, :sms_notifications
    ])
  end

  def after_sign_in_path_for(resource)
    dashboard_path
  end

  def after_sign_out_path_for(resource_or_scope)
    root_path
  end

  private

  def user_not_authorized
    flash[:alert] = "You are not authorized to perform this action."
    redirect_to(request.referrer || dashboard_path)
  end

  # Helper to scope queries to current organization
  def current_organization
    Current.organization
  end
  helper_method :current_organization
end
