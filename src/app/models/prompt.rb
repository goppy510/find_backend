# frozen_string_literal: true

class Prompt < ApplicationRecord
  belongs_to :category
  belongs_to :generative_ai_model
  belongs_to :user

  has_many :likes, dependent: :destroy
  has_many :users_who_liked, through: :likes, source: :user

  has_many :bookmarks, dependent: :destroy
  has_many :users_who_bookmarked, through: :bookmarks, source: :user
end
