# frozen_string_literal: true

require 'factory_bot_rails'
require 'faker'

FactoryBot.define do
  factory :permission do
    user
    resource
  end
end
