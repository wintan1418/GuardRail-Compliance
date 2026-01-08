class Subscription < ApplicationRecord
  belongs_to :organization
  belongs_to :plan

  validates :status, inclusion: { in: %w[trialing active past_due canceled unpaid] }

  scope :active, -> { where(status: %w[trialing active]) }
  scope :trialing, -> { where(status: 'trialing') }

  def active?
    status.in?(%w[trialing active])
  end

  def trialing?
    status == 'trialing'
  end

  def trial_days_remaining
    return 0 unless trialing? && trial_ends_at
    [(trial_ends_at.to_date - Date.current).to_i, 0].max
  end

  def at_user_limit?
    return false unless plan.max_users
    organization.users.count >= plan.max_users
  end

  def at_document_limit?
    return false unless plan.max_documents
    organization.documents.count >= plan.max_documents
  end

  def can_use_sms?
    plan.sms_enabled?
  end

  def can_use_slack?
    plan.slack_enabled?
  end
end
