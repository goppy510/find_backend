#frozen_string_literal: true

require 'rails_helper'
require 'rspec-rails'
require 'faker'

describe ActivationMailer do
  let!(:from_content) { Settings[:mail][:from] }
  let!(:signature) do
    "----------------------------------\r\n" \
    "Findお問い合わせ\r\n" \
    "support@find-market.co.jp\r\n" \
    "運営会社: 株式会社メイクリード\r\n" \
    "連絡先: 〒214-0014 神奈川県川崎市多摩区登戸2432-1 Bluewater Building7F\r\n" \
    "----------------------------------\r\n" \
    "Copyright (C) MakeLead Co.,Ltd. All Rights Reserved\r\n\r\n" \
  end

  describe '#send_activation_email' do
    before do
      travel_to Time.zone.local(2023, 05, 10, 3, 0, 0)
    end

    context 'メールが送信された場合' do
      let!(:email) { Faker::Internet.email }
      let!(:user) { create(:user, email: email) }
      let!(:auth) { Auth::AuthTokenService.new(lifetime: Auth.token_signup_lifetime, payload: { sub: user.id, type: 'activation' }) }
      let!(:token) { auth.token }
      let!(:expires_at) { Time.at(auth.payload[:exp]) }
      let!(:url) { "http://localhost:8080/activation?token=#{token}" }
      let!(:subject_content) { '【find-market】本登録のお願い' }
      let!(:body) do
        "#{email} 様\r\n\r\n" \
        "Find カスタマーサポートです。\r\n\r\n" \
        "この度は、ビジネス向け生成AIプロンプトデータベース「Find（ファインド）」へのご登録、誠にありがとうございます。\r\n\r\n" \
        "以下のリンクをクリックして本登録を完了してください。\r\n\r\n" \
        "#{url}\r\n\r\n" \
        "有効期限（1時間）: #{expires_at.in_time_zone('Tokyo').strftime('%Y-%m-%d %H:%M:%S')}\r\n\r\n" \
        "もしこのメールに心当たりがない場合は、削除していただきますようお願い申し上げます。\r\n\r\n" \
        "ご不明な点がある場合は、下記の当サポートまでお問い合わせください。\r\n\r\n" \
        "#{signature}"
      end

      it '送信元が正しいこと' do
        ActivationMailer.send_activation_email(email, token, expires_at).deliver_now
        mail = ActionMailer::Base.deliveries.last
        expect(mail.from.first).to eq(from_content)
      end

      it '宛先が正しいこと' do
        ActivationMailer.send_activation_email(email, token, expires_at).deliver_now
        mail = ActionMailer::Base.deliveries.last
        expect(mail.to.first).to eq(email)
      end
    
      it '件名が正しいこと' do
        ActivationMailer.send_activation_email(email, token, expires_at).deliver_now
        mail = ActionMailer::Base.deliveries.last
        expect(mail.subject).to eq(subject_content)
      end

      it '有効期限が正しいこと' do
        expect(expires_at.strftime('%Y-%m-%d %H:%M:%S')).to eq((Time.current + 1.hour).strftime('%Y-%m-%d %H:%M:%S'))
      end

      it '本文が正しいこと' do
        ActivationMailer.send_activation_email(email, token, expires_at).deliver_now
        mail = ActionMailer::Base.deliveries.last
        expect(mail.body.encoded).to eq(body)
      end
    end
  end
end
