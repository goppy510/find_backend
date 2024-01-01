# frozen_string_literal: true

require 'factory_bot_rails'
require 'faker'

FactoryBot.define do
  factory :prompt do
    uuid { SecureRandom.uuid }
    association :contract
    about { Faker::Lorem.sentence }
    title { Faker::Lorem.sentence }
    input_example { Faker::Lorem.sentence }
    output_example { Faker::Lorem.sentence }
    prompt { Faker::Lorem.sentence }
    association :user
    deleted { false }
    created_at { Time.zone.now }
    updated_at { Time.zone.now }

    after(:build) do |prompt|
      prompt.category ||= 
        Category.any? ? Category.order(Arel.sql('RAND()')).first : create(:category)
      prompt.generative_ai_model ||= 
        GenerativeAiModel.any? ? GenerativeAiModel.order(Arel.sql('RAND()')).first : create(:generative_ai_model)
    end
  end
end
