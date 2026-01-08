class Document < ApplicationRecord
  # Associations
  belongs_to :organization
  belongs_to :compliance_category, optional: true
  belongs_to :uploaded_by, class_name: 'User'
  belongs_to :assigned_to, class_name: 'User', optional: true
  has_many :reminders, dependent: :destroy

  # Active Storage
  has_one_attached :file
  has_one_attached :thumbnail

  # Validations
  validates :name, presence: true, length: { maximum: 255 }
  validates :status, inclusion: { in: %w[active expiring_soon expired archived] }
  validates :document_type, inclusion: { 
    in: %w[license certificate policy agreement training other] 
  }, allow_blank: true

  # Scopes
  scope :active, -> { where(status: 'active') }
  scope :expiring_soon, -> { where(status: 'expiring_soon') }
  scope :expired, -> { where(status: 'expired') }
  scope :archived, -> { where(status: 'archived') }
  scope :with_expiration, -> { where.not(expiration_date: nil) }
  scope :expiring_within, ->(days) { 
    where('expiration_date <= ? AND expiration_date > ?', Date.current + days.days, Date.current) 
  }
  scope :by_category, ->(category_id) { where(compliance_category_id: category_id) }

  # Callbacks
  after_save :update_status!
  after_save :schedule_reminders, if: :should_schedule_reminders?
  after_save :update_organization_health_score

  # Instance Methods
  def days_until_expiry
    return nil unless expiration_date
    (expiration_date - Date.current).to_i
  end

  def expired?
    expiration_date.present? && expiration_date < Date.current
  end

  def expiring_soon?(threshold = 30)
    return false unless expiration_date
    days_until_expiry&.between?(1, threshold)
  end

  def compliant?
    !expired? && !expiring_soon?
  end

  def status_color
    case status
    when 'active' then days_until_expiry.nil? || days_until_expiry > 60 ? 'success' : 'warning'
    when 'expiring_soon' then days_until_expiry <= 7 ? 'danger' : 'warning'
    when 'expired' then 'danger'
    else 'neutral'
    end
  end

  def update_status!
    new_status = calculate_status
    update_column(:status, new_status) if status != new_status
  end

  private

  def calculate_status
    return 'archived' if status == 'archived'
    return 'active' unless expiration_date

    days = days_until_expiry
    if days <= 0
      'expired'
    elsif days <= 60
      'expiring_soon'
    else
      'active'
    end
  end

  def should_schedule_reminders?
    auto_remind && expiration_date.present? && saved_change_to_expiration_date?
  end

  def schedule_reminders
    ScheduleRemindersJob.perform_later(id)
  end

  def update_organization_health_score
    organization.update_health_score!
  end
end
