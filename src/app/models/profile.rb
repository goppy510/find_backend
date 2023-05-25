class Profile < ApplicationRecord
  belongs_to :user
  belongs_to :industry
  belongs_to :position
  belongs_to :business_model
  belongs_to :employee_count
end
