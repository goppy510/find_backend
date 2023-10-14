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
        let!(:logins) do
          {
            logins: {
              email: email,
              password: password
            }
          }
        end
        let!(:user) { create(:user, email:, password:, activated: true) }
        let!(:payload) do
          {
            sub: user.id,
            type: 'api'
          }
        end
        let!(:auth) { generate_token(payload:) }
        let!(:token) { auth.token }

        it 'tokenとexpがレスポンスとして返ってくること' do
          res = LoginService.login(logins)
          expect(res[:expires]).to eq(Time.zone.local(2023, 5, 24, 3, 0, 0))
          expect(res[:token]).to eq(token)
        end
      end
    end

    context '異常系' do
      context 'メールアドレスが引数にない場合' do
        let!(:password) { 'P@ssw0rd' }
        let!(:logins) do
          {
            logins: {
              email: nil,
              password: password
            }
          }
        end

        it 'ArgumentErrorがスローされること' do
          expect { LoginService.login(logins) }.to raise_error(ArgumentError, 'emailがありません')
        end
      end

      context 'パスワードが引数にない場合' do
        let!(:email) { Faker::Internet.email }
        let!(:logins) do
          {
            logins: {
              email: email,
              password: nil
            }
          }
        end

        it 'ArgumentErrorがスローされること' do
          expect { LoginService.login(logins) }.to raise_error(ArgumentError, 'passwordがありません')
        end
      end

      context 'emailのフォーマットが不正な場合' do
        let!(:email) { 'test' }
        let!(:password) { 'P@ssw0rd' }
        let!(:logins) do
          {
            logins: {
              email: email,
              password: password
            }
          }
        end

        it 'EmailFormatErrorがスローされること' do
          expect { LoginService.login(logins) }.to raise_error(LoginService::EmailFormatError)
        end
      end

      context 'passwordのフォーマットが不正な場合' do
        let!(:email) { Faker::Internet.email }
        let!(:password) { 'test' }
        let!(:logins) do
          {
            logins: {
              email: email,
              password: password
            }
          }
        end

        it 'PasswordFormatErrorがスローされること' do
          expect { LoginService.login(logins) }.to raise_error(LoginService::PasswordFormatError)
        end
      end
    end
  end
end
