# frozen_string_literal: true

require 'rails_helper'
require 'rspec-rails'
require 'faker'

describe LoginService do
  include SessionModule
  describe '#login' do
    context '正常系' do
      context '正しいメールアドレスとパスワードを受け取った場合' do
        before do
          travel_to Time.zone.local(2023, 5, 10, 3, 0, 0)
        end

        let!(:email) { Faker::Internet.email }
        let!(:password) { 'P@ssw0rd' }
        let!(:user) { create(:user, email:, password:, activated: true) }
        let!(:profile) { create(:profile, user_id: user.id) }
        let!(:payload) do
          {
            sub: user.id,
            type: 'api'
          }
        end
        let!(:auth) { generate_token(payload:) }
        let!(:token) { auth.token }

        it 'tokenとexpがレスポンスとして返ってくること' do
          service = LoginService.new(email, password)
          res = service.login
          expect(res[:expires]).to eq(Time.zone.local(2023, 5, 24, 3, 0, 0))
          expect(res[:token]).to eq(token)
        end
      end
    end

    context '異常系' do
      context 'メールアドレスが引数にない場合' do
        let!(:password) { 'P@ssw0rd' }

        it 'ArgumentErrorがスローされること' do
          expect { SignupService.new(nil, password) }.to raise_error(ArgumentError, 'emailまたはpasswordがありません')
        end
      end

      context 'パスワードが引数にない場合' do
        let!(:email) { Faker::Internet.email }

        it 'ArgumentErrorがスローされること' do
          expect { SignupService.new(email, nil) }.to raise_error(ArgumentError, 'emailまたはpasswordがありません')
        end
      end
    end
  end
end
