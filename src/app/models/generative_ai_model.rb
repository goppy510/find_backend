# frozen_string_literal: true

class GenerativeAiModel < ApplicationRecord
  has_many :prompts, dependent: :nullify
end
