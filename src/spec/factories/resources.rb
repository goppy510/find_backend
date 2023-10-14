# frozen_string_literal: true

require 'factory_bot_rails'
require 'faker'

FactoryBot.define do
  names = [
    'contract',
    'user',
    'permission',
    'create_prompt',
    'read_prompt',
    'update_prompt',
    'delete_prompt'
  ]

  factory :resource do
    name { names.sample }
  end
end
