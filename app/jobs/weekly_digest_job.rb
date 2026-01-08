class WeeklyDigestJob < ApplicationJob
  queue_as :default

  def perform
    User.with_notifications_enabled.includes(:organization).find_each do |user|
      ReminderMailer.weekly_digest(user).deliver_later
    end

    Rails.logger.info "Queued weekly digest emails for all users"
  end
end
