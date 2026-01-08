class SlackNotificationService
  def initialize(reminder)
    @reminder = reminder
    @document = reminder.document
    @user = reminder.user
    @organization = @document.organization
    @settings = @organization.notification_setting
  end

  def send!
    return unless can_send?

    webhook_url = @settings.slack_webhook_url

    payload = build_payload
    
    response = HTTP.post(webhook_url, json: payload)

    unless response.status.success?
      raise "Slack webhook failed: #{response.status}"
    end

    Rails.logger.info "Slack notification sent for reminder #{@reminder.id}"
  end

  private

  def can_send?
    return false unless @settings&.slack_enabled?
    return false unless @settings&.slack_webhook_url.present?
    true
  end

  def build_payload
    days = @document.days_until_expiry
    urgency = days <= 7 ? 'danger' : (days <= 30 ? 'warning' : 'good')

    {
      username: 'GuardRail Compliance',
      icon_emoji: ':shield:',
      attachments: [
        {
          color: urgency,
          pretext: urgency_text(days),
          title: @document.name,
          title_link: document_url,
          fields: [
            {
              title: 'Expiration Date',
              value: @document.expiration_date.strftime('%B %d, %Y'),
              short: true
            },
            {
              title: 'Days Remaining',
              value: days <= 0 ? 'EXPIRED' : "#{days} days",
              short: true
            },
            {
              title: 'Category',
              value: @document.compliance_category&.name || 'Uncategorized',
              short: true
            },
            {
              title: 'Assigned To',
              value: @user.full_name,
              short: true
            }
          ],
          footer: @organization.name,
          ts: Time.current.to_i
        }
      ]
    }
  end

  def urgency_text(days)
    if days <= 0
      "🚨 *EXPIRED* - Immediate action required!"
    elsif days <= 7
      "⚠️ *URGENT* - Expires in #{days} days"
    elsif days <= 30
      "📋 *Reminder* - Expires in #{days} days"
    else
      "📅 *Upcoming* - Expires in #{days} days"
    end
  end

  def document_url
    Rails.application.routes.url_helpers.document_url(
      @document,
      host: Rails.application.config.action_mailer.default_url_options[:host] || 'localhost:5000'
    )
  end
end
