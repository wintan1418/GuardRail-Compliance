class AuditLog < ApplicationRecord
  belongs_to :organization
  belongs_to :user, optional: true

  validates :action, presence: true

  scope :recent, -> { order(created_at: :desc).limit(50) }
  scope :for_resource, ->(type, id) { where(resource_type: type, resource_id: id) }

  ACTIONS = %w[
    document_uploaded document_updated document_deleted document_viewed
    reminder_sent reminder_acknowledged
    user_invited user_joined user_removed
    settings_updated
    login logout
    report_generated
  ].freeze

  def self.log(organization:, action:, user: nil, resource: nil, metadata: {}, ip_address: nil)
    create!(
      organization: organization,
      user: user,
      action: action,
      resource_type: resource&.class&.name,
      resource_id: resource&.id,
      metadata: metadata,
      ip_address: ip_address
    )
  end
end
