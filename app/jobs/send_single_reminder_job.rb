class SendSingleReminderJob < ApplicationJob
  queue_as :default

  def perform(reminder_id)
    reminder = Reminder.find_by(id: reminder_id)
    return unless reminder && reminder.status == 'pending'

    begin
      case reminder.channel
      when 'email'
        ReminderMailer.expiration_warning(reminder).deliver_now
      when 'sms'
        SmsNotificationService.new(reminder).send!
      when 'slack'
        SlackNotificationService.new(reminder).send!
      end

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
end
