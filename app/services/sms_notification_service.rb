class SmsNotificationService
  def initialize(reminder)
    @reminder = reminder
    @document = reminder.document
    @user = reminder.user
    @organization = @document.organization
    @settings = @organization.notification_setting
  end

  def send!
    return unless can_send?

    client = Twilio::REST::Client.new(
      Rails.application.credentials.dig(:twilio, :account_sid) || ENV['TWILIO_ACCOUNT_SID'],
      Rails.application.credentials.dig(:twilio, :auth_token) || ENV['TWILIO_AUTH_TOKEN']
    )

    from_number = @settings.twilio_phone_number || 
                  Rails.application.credentials.dig(:twilio, :phone_number) ||
                  ENV['TWILIO_PHONE_NUMBER']

    message = build_message

    client.messages.create(
      from: from_number,
      to: @user.phone,
      body: message
    )

    Rails.logger.info "SMS sent to #{@user.phone} for reminder #{@reminder.id}"
  end

  private

  def can_send?
    return false unless @user.phone.present?
    return false unless @settings&.sms_enabled?
    true
  end

  def build_message
    days = @document.days_until_expiry

    if days <= 0
      "🚨 GUARDRAIL ALERT: #{@document.name} has EXPIRED. Please update immediately. - #{@organization.name}"
    elsif days <= 7
      "⚠️ URGENT: #{@document.name} expires in #{days} days. Action required. - #{@organization.name}"
    else
      "📋 Reminder: #{@document.name} expires on #{@document.expiration_date.strftime('%b %d')}. - #{@organization.name}"
    end
  end
end
