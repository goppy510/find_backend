# frozen_string_literal: true

require 'rails_helper'
require 'rspec-rails'
require 'faker'

describe LoginService do
  include SessionModule

  describe '#create' do
    context '正常系' do
      context '正しいメールアドレスとパスワードを受け取った場合' do
        before do
          travel_to Time.zone.local(2023, 5, 10, 3, 0, 0)
          allow(Login::LoginDomain).to receive(:create)
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

        it 'Login::LoginDomain.createが呼ばれること' do
          LoginService.create(logins:, token:)
          expect(Login::LoginDomain).to have_received(:create)
        end
      end
    end
  end
end
