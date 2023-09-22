# frozen_string_literal: true

require 'factory_bot_rails'
require 'faker'

FactoryBot.define do
  factory :bookmark do
    association :user
    association :prompt

    # 任意でtimestamp等の属性を追加できます
    created_at { Time.zone.now }
    updated_at { Time.zone.now }
  end
end
