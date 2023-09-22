# frozen_string_literal: true

require 'factory_bot_rails'
require 'faker'

FactoryBot.define do
  names = [
    'GPT-3.5',
    'GPT-4'
  ]

  factory :generative_ai_model do
    name { names.sample }
  end
end
