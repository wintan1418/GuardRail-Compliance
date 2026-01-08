class NotificationSetting < ApplicationRecord
  belongs_to :organization

  validates :escalation_after_days, numericality: { greater_than: 0 }, allow_nil: true

  def channels_enabled
    channels = []
    channels << 'email' if email_enabled?
    channels << 'sms' if sms_enabled?
    channels << 'slack' if slack_enabled?
    channels
  end

  def can_send_sms?
    sms_enabled? && twilio_phone_number.present?
  end

  def can_send_slack?
    slack_enabled? && slack_webhook_url.present?
  end
end
