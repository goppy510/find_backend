class Category < ApplicationRecord
  has_many :prompts, dependent: :nullify
end
