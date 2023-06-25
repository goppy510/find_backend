# frozen_string_literal: true

require 'rails_helper'
require 'rspec-rails'
require 'faker'

describe ActivationService do
  include SessionModule

  describe '#activate' do
    context '正常系' do
      context '有効なトークンを受け取った場合' do
        before do
          travel_to Time.zone.local(2023, 5, 10, 3, 0, 0)
        end

        let!(:user) { create(:user) }
        let!(:payload) do
          {
            sub: user.id,
            type: 'activation'
          }
        end
        let!(:auth) { generate_token(payload:, lifetime: Auth.token_signup_lifetime) }
        let!(:token) { auth.token }

        it 'usersのactivatedがtrueになること' do
          service = ActivationService.new(token)
          service.activate
          expect(User.find(user.id).activated).to be_truthy
        end
      end
    end

    context '異常系' do
      context '不正なトークンを受け取った場合' do
        before do
          travel_to Time.zone.local(2023, 5, 10, 3, 0, 0)
        end

        let!(:user) { create(:user) }
        let!(:token) do
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9
            .eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ
              .SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c'
        end

        it 'AuthenticationErrorがスローされること' do
          service = ActivationService.new(token)
          expect { service.activate }.to raise_error(AuthenticationError)
        end
      end
    end
  end

  describe '#self.activate' do
    context '正常系' do
      context '有効なトークンを受け取った場合' do
        before do
          travel_to Time.zone.local(2023, 5, 10, 3, 0, 0)
        end

        let!(:user) { create(:user) }
        let!(:payload) do
          {
            sub: user.id,
            type: 'activation'
          }
        end
        let!(:auth) { generate_token(payload:, lifetime: Auth.token_signup_lifetime) }
        let!(:token) { auth.token }

        it 'usersのactivatedがtrueになること' do
          ActivationService.activate(token)
          expect(User.find(user.id).activated).to be_truthy
        end
      end
    end
  end
end
