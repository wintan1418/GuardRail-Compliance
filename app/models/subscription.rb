class Subscription < ApplicationRecord
  belongs_to :organization
  belongs_to :plan
end
