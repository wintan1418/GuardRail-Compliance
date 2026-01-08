class Document < ApplicationRecord
  belongs_to :organization
  belongs_to :compliance_category
end
