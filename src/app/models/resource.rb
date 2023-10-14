# frozen_string_literal: true

class Resource < ApplicationRecord
  has_many :permissions
  has_many :users, through: :permissions
end
