class SendRemindersJob < ApplicationJob
  queue_as :default

  def perform
    due_reminders = Reminder.due.includes(:document, :user, document: :organization)

    due_reminders.find_each do |reminder|
      begin
        send_reminder(reminder)
        reminder.mark_as_sent!
        
        AuditLog.log(
          organization: reminder.document.organization,
          action: 'reminder_sent',
          resource: reminder.document,
          metadata: { 
            channel: reminder.channel,
            user_id: reminder.user_id,
            escalation_level: reminder.escalation_level
          }
        )
      rescue => e
        Rails.logger.error "Failed to send reminder #{reminder.id}: #{e.message}"
        reminder.update!(status: 'failed')
      end
    end

    # Check for reminders that need escalation
    check_for_escalations
  end

  private

  def send_reminder(reminder)
    case reminder.channel
    when 'email'
      ReminderMailer.expiration_warning(reminder).deliver_later
    when 'sms'
      SmsNotificationService.new(reminder).send!
    when 'slack'
      SlackNotificationService.new(reminder).send!
    end
  end

  def check_for_escalations
    # Find documents with sent reminders that haven't been acknowledged
    # and are past the escalation threshold
    Organization.find_each do |org|
      settings = org.notification_setting
      next unless settings&.escalation_enabled?

      threshold_date = settings.escalation_after_days.days.ago

      # Find reminders that were sent but not acknowledged
      stale_reminders = Reminder
        .joins(:document)
        .where(documents: { organization_id: org.id })
        .where(status: 'sent')
        .where('sent_at < ?', threshold_date)
        .where(escalation_level: 0..1)

      stale_reminders.find_each do |reminder|
        EscalateReminderJob.perform_later(reminder.id)
      end
    end
  end
end
