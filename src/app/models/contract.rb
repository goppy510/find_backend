# frozen_string_literal: true

class Contract < ApplicationRecord
  belongs_to :admin_user, class_name: 'User'
  has_many :users, dependent: :destroy
end
