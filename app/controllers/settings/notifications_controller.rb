class Settings::NotificationsController < ApplicationController
  before_action :set_notification_setting

  def show
  end

  def update
    if @notification_setting.update(notification_setting_params)
      redirect_to settings_notifications_path, notice: 'Notification settings updated successfully.'
    else
      render :show, status: :unprocessable_entity
    end
  end

  private

  def set_notification_setting
    @notification_setting = current_organization.notification_setting || 
                            current_organization.create_notification_setting!
  end

  def notification_setting_params
    params.require(:notification_setting).permit(
      :email_enabled, :sms_enabled, :slack_enabled,
      :slack_webhook_url, :twilio_phone_number,
      :escalation_enabled, :escalation_after_days,
      reminder_intervals: []
    )
  end
end
