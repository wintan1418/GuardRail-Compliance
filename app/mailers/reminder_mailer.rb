class ReminderMailer < ApplicationMailer
  default from: 'notifications@guardrail.com'

  def expiration_warning(reminder)
    @reminder = reminder
    @document = reminder.document
    @user = reminder.user
    @organization = @document.organization
    @days_until_expiry = @document.days_until_expiry

    subject = case @days_until_expiry
    when ..0
      "🚨 EXPIRED: #{@document.name} has expired"
    when 1..7
      "⚠️ URGENT: #{@document.name} expires in #{@days_until_expiry} days"
    when 8..30
      "📋 Reminder: #{@document.name} expires in #{@days_until_expiry} days"
    else
      "📋 Upcoming: #{@document.name} expires in #{@days_until_expiry} days"
    end

    # Add escalation indicator
    if @reminder.escalation_level > 0
      subject = "🔺 ESCALATED: #{subject}"
    end

    mail(
      to: @user.email,
      subject: subject
    )
  end

  def weekly_digest(user)
    @user = user
    @organization = user.organization
    @expiring_soon = @organization.documents
      .where('expiration_date <= ?', 30.days.from_now)
      .where('expiration_date > ?', Date.current)
      .order(:expiration_date)
    @expired = @organization.documents.expired

    return if @expiring_soon.empty? && @expired.empty?

    mail(
      to: @user.email,
      subject: "📊 Weekly Compliance Summary - #{@organization.name}"
    )
  end
end
