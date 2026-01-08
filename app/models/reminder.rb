class Reminder < ApplicationRecord
  belongs_to :document
  belongs_to :user

  validates :scheduled_at, presence: true
  validates :channel, presence: true, inclusion: { in: %w[email sms slack] }
  validates :status, inclusion: { in: %w[pending sent failed acknowledged] }
  validates :escalation_level, numericality: { in: 0..2 }

  scope :pending, -> { where(status: 'pending') }
  scope :sent, -> { where(status: 'sent') }
  scope :due, -> { pending.where('scheduled_at <= ?', Time.current) }
  scope :for_channel, ->(channel) { where(channel: channel) }

  def sent?
    status == 'sent'
  end

  def mark_as_sent!
    update!(status: 'sent', sent_at: Time.current)
  end

  def mark_as_acknowledged!
    update!(status: 'acknowledged')
  end

  def escalate!
    return if escalation_level >= 2
    
    new_level = escalation_level + 1
    new_user = case new_level
               when 1 then document.organization.admins.first
               when 2 then document.organization.owner
               end

    update!(escalation_level: new_level, user: new_user) if new_user
  end
end
