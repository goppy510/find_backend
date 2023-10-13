# frozen_string_literal: true

class User < ApplicationRecord
  has_secure_password
  has_one :profile

  has_many :likes, dependent: :destroy
  has_many :liked_prompts, through: :likes, source: :prompt

  has_many :bookmarks, dependent: :destroy
  has_many :bookmarked_prompts, through: :bookmarks, source: :prompt
  
  has_many :prompts, dependent: :nullify

  has_many :permissions
  has_many :resources, through: :permissions
  belongs_to :contract, optional: true
end
