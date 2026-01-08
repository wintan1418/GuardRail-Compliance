class EscalateReminderJob < ApplicationJob
  queue_as :default

  def perform(reminder_id)
    reminder = Reminder.find_by(id: reminder_id)
    return unless reminder && reminder.status == 'sent'
    return if reminder.escalation_level >= 2

    document = reminder.document
    organization = document.organization
    
    # Determine next escalation recipient
    next_level = reminder.escalation_level + 1
    next_recipient = case next_level
    when 1 then organization.admins.where.not(id: reminder.user_id).first
    when 2 then organization.owner
    end

    return unless next_recipient && next_recipient != reminder.user

    # Create escalated reminder
    new_reminder = document.reminders.create!(
      user: next_recipient,
      scheduled_at: Time.current,
      channel: reminder.channel,
      status: 'pending',
      escalation_level: next_level
    )

    # Mark original as escalated
    reminder.update!(escalation_level: next_level)

    # Send immediately
    SendSingleReminderJob.perform_later(new_reminder.id)

    Rails.logger.info "Escalated reminder #{reminder.id} to level #{next_level}, new reminder #{new_reminder.id}"
  end
end
