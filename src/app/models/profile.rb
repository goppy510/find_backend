# frozen_string_literal: true

class Profile < ApplicationRecord
  belongs_to :user
  belongs_to :employee_count
  belongs_to :industry
  belongs_to :position
  belongs_to :business_model
end
