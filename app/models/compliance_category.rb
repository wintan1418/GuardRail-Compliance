class ComplianceCategory < ApplicationRecord
  belongs_to :organization
  has_many :documents, dependent: :nullify

  validates :name, presence: true, length: { maximum: 100 }
  validates :name, uniqueness: { scope: :organization_id }
  validates :color, format: { with: /\A#[0-9A-Fa-f]{6}\z/, message: 'must be a valid hex color' }

  scope :ordered, -> { order(:name) }

  def documents_count
    documents.count
  end

  def expiring_soon_count
    documents.expiring_soon.count
  end

  def expired_count
    documents.expired.count
  end
end
