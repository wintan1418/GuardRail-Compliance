class Organization < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: :slugged

  # Associations
  has_many :users, dependent: :destroy
  has_many :documents, dependent: :destroy
  has_many :compliance_categories, dependent: :destroy
  has_one :notification_setting, dependent: :destroy
  has_one :subscription, dependent: :destroy
  has_many :audit_logs, dependent: :destroy

  # Validations
  validates :name, presence: true, length: { maximum: 255 }
  validates :slug, presence: true, uniqueness: true
  validates :industry, presence: true, inclusion: { in: %w[medical dental legal other] }
  validates :compliance_health_score, numericality: { in: 0..100 }, allow_nil: true

  # Callbacks
  after_create :create_default_notification_setting
  after_create :create_default_categories

  # Instance Methods
  def owner
    users.find_by(role: 'owner')
  end

  def admins
    users.where(role: %w[owner admin])
  end

  def calculate_health_score
    docs = documents.where.not(expiration_date: nil)
    return 100 if docs.empty?

    scores = docs.map do |doc|
      days_until = (doc.expiration_date - Date.current).to_i
      case days_until
      when ..0    then 0    # Expired
      when 1..7   then 25   # Critical
      when 8..30  then 50   # Warning
      when 31..60 then 75   # Attention
      else             100  # Healthy
      end
    end

    (scores.sum.to_f / docs.count).round
  end

  def update_health_score!
    update!(compliance_health_score: calculate_health_score)
  end

  private

  def create_default_notification_setting
    create_notification_setting! unless notification_setting
  end

  def create_default_categories
    default_categories = [
      { name: 'Licenses', color: '#3B82F6' },
      { name: 'Certifications', color: '#10B981' },
      { name: 'Insurance', color: '#F59E0B' },
      { name: 'Policies', color: '#8B5CF6' },
      { name: 'Agreements', color: '#EC4899' }
    ]

    default_categories.each do |cat|
      compliance_categories.create!(cat)
    end
  end
end
