# frozen_string_literal: true

require 'factory_bot_rails'
require 'faker'

FactoryBot.define do
  factory :contract do
    association :admin_user, factory: :user
    max_member_count { 5 }
  end
end
