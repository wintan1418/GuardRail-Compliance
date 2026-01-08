class User < ApplicationRecord
  # Include default devise modules
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Associations
  belongs_to :organization
  has_many :uploaded_documents, class_name: 'Document', foreign_key: 'uploaded_by_id', dependent: :nullify
  has_many :assigned_documents, class_name: 'Document', foreign_key: 'assigned_to_id', dependent: :nullify
  has_many :reminders, dependent: :destroy
  has_many :audit_logs, dependent: :nullify

  # Validations
  validates :first_name, presence: true, length: { maximum: 100 }
  validates :last_name, presence: true, length: { maximum: 100 }
  validates :role, presence: true, inclusion: { in: %w[owner admin staff] }
  validates :phone, format: { with: /\A\+?[\d\s\-()]+\z/, message: 'invalid format' }, allow_blank: true

  # Scopes
  scope :owners, -> { where(role: 'owner') }
  scope :admins, -> { where(role: %w[owner admin]) }
  scope :staff, -> { where(role: 'staff') }
  scope :with_notifications_enabled, -> { where(email_notifications: true) }

  # Callbacks
  before_validation :set_default_role, on: :create

  # Instance Methods
  def full_name
    "#{first_name} #{last_name}".strip
  end

  def display_name
    title.present? ? "#{title} #{full_name}" : full_name
  end

  def owner?
    role == 'owner'
  end

  def admin?
    role.in?(%w[owner admin])
  end

  def staff?
    role == 'staff'
  end

  def license_expired?
    license_expiration.present? && license_expiration < Date.current
  end

  def license_expiring_soon?(days = 30)
    return false unless license_expiration.present?
    license_expiration <= Date.current + days.days && license_expiration > Date.current
  end

  private

  def set_default_role
    self.role ||= 'staff'
  end
end
