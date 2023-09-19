# frozen_string_literal: true

require 'factory_bot_rails'
require 'faker'

FactoryBot.define do
  names = [
    'IT・情報通信業',
    '金融・保険業',
    '不動産業',
    '交通・運輸業',
    '医療・福祉',
    '教育・学習支援業',
    '旅行・宿泊・飲食業',
    'エンターテインメント・マスコミ',
    '広告・マーケティング',
    'コンサルティング業',
    'その他'
  ]

  factory :category do
    name { names.sample }
  end
end
