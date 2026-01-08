class Plan < ApplicationRecord
  has_many :subscriptions, dependent: :restrict_with_error

  validates :name, presence: true, uniqueness: true
  validates :stripe_price_id, presence: true, uniqueness: true
  validates :price_cents, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :interval, inclusion: { in: %w[month year] }

  scope :active, -> { where(active: true) }
  scope :ordered_by_price, -> { order(:price_cents) }

  def price_in_dollars
    price_cents / 100.0
  end

  def formatted_price
    "$#{price_in_dollars.round}/#{interval}"
  end

  def feature_enabled?(feature_name)
    features&.dig(feature_name.to_s) == true
  end
end
