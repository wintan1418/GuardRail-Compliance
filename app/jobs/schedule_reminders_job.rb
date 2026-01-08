class ScheduleRemindersJob < ApplicationJob
  queue_as :default

  def perform(document_id)
    document = Document.find_by(id: document_id)
    return unless document && document.expiration_date && document.auto_remind

    # Clear existing pending reminders for this document
    document.reminders.pending.destroy_all

    # Get reminder intervals from document or organization settings
    intervals = document.reminder_days.presence || 
                document.organization.notification_setting&.reminder_intervals ||
                [90, 60, 30, 7]

    # Get notification channels
    settings = document.organization.notification_setting
    channels = settings&.channels_enabled || ['email']

    # Determine who should receive reminders
    recipients = determine_recipients(document)

    intervals.each do |days_before|
      reminder_date = document.expiration_date - days_before.days
      
      # Skip if reminder date is in the past
      next if reminder_date <= Date.current

      recipients.each do |user|
        channels.each do |channel|
          # Skip SMS/Slack if user doesn't have the required info
          next if channel == 'sms' && user.phone.blank?
          next if channel == 'slack' && !settings&.can_send_slack?

          document.reminders.create!(
            user: user,
            scheduled_at: reminder_date.to_time.change(hour: 9), # 9 AM
            channel: channel,
            status: 'pending',
            escalation_level: 0
          )
        end
      end
    end

    Rails.logger.info "Scheduled #{document.reminders.pending.count} reminders for document #{document.id}"
  end

  private

  def determine_recipients(document)
    recipients = []
    
    # Primary recipient is the assigned user or uploader
    primary = document.assigned_to || document.uploaded_by
    recipients << primary if primary

    # Also notify admins if configured
    if document.organization.notification_setting&.escalation_enabled?
      document.organization.admins.each do |admin|
        recipients << admin unless recipients.include?(admin)
      end
    end

    recipients.compact.uniq
  end
end
