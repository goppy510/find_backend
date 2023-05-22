#frozen_string_literal: true

require 'rails_helper'
require 'rspec-rails'
require 'faker'

describe RegsitrationMailer do
  let!(:from_content) { Settings[:mail][:from] }
  let!(:signature) do
    "----------------------------------\r\n" \
    "find-marketお問い合わせ\r\n" \
    "support@find-market.co.jp\r\n" \
    "運営会社: 株式会社メイクリード\r\n" \
    "連絡先: 〒102-0074 東京都千代田区九段南1丁目5番6号りそな九段ビル5F KSフロア\r\n" \
    "----------------------------------\r\n" \
    "Copyright (C) MakeLead Co.,Ltd. All Rights Reserved\r\n\r\n" \
  end

  describe '#send_registration_mail' do
    before do
      travel_to Time.zone.local(2023, 05, 10, 3, 0, 0)
      RegsitrationMailer.send_activation_email(email, token, expires_at).deliver_now
    end

    context 'メールが送信された場合' do
      let!(:email) { Faker::Internet.email }
      let!(:registration_token) { crate(:registration_token) }
      let!(:url) { "localhost:3000/activation?token=#{registration_token.token}" }
      let!(:subject) { '【find-market】本登録のお願い' }
      let!(:body) do
        "#{email} 様 \r\n\r\n" \

        "find-market カスタマーサポートです。\r\n\r\n" \

        "この度は、ビジネス向け生成AIプロンプトデータベース「find-market（ファインドマーケット）」へのご登録、誠にありがとうございます。\r\n\r\n" \

        "以下のリンクをクリックして本登録を完了してください。\r\n\r\n" \

        "#{url}\r\n\r\n" \

        "有効期限（1時間）: #{registration_token.expires_at}\r\n\r\n" \

        "もしこのメールに心当たりがない場合は、削除していただきますようお願い申し上げます。\r\n\r\n" \

        "ご不明な点がある場合は、下記の当サポートまでお問い合わせください。\r\n\r\n" \

        "#{signature}\r\n\r\n" \
      end
    end
  end
end
