# frozen_string_literal: true

require 'factory_bot_rails'
require 'faker'

FactoryBot.define do
  factory :business_model do
    name { ['BtoB', 'BtoC', 'その他'].sample }
  end
end
