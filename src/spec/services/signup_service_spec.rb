# frozen_string_literal: true

require 'rails_helper'
require 'rspec-rails'
require 'faker'

describe SignupService do
  include SessionModule

  before do
    travel_to Time.zone.local(2023, 5, 10, 3, 0, 0)
    allow(ActivationMailService).to receive(:activation_email)
  end
  describe '#self.sigunp' do
    context '正常系' do
      let!(:email) { Faker::Internet.email }
      let!(:password) { 'P@ssw0rd' }
      let!(:signups) do
        {
          signups: {
            email: email,
            password: password
          }
        }
      end
      context 'contract権限を持ったuserのtokenが渡された場合' do
        let!(:user) { create(:user, activated: true) }
        let!(:contract) { Resource.find_by(name: 'contract') }
        let!(:permission) { create(:permission, user_id: user.id, resource_id: contract.id) }
        let!(:payload) do
          {
            sub: user.id,
            type: 'api'
          }
        end
        let!(:auth) { generate_token(payload:) }
        let!(:token) { auth.token }

        before do
          allow(Signup::ContractSignupDomain).to receive(:signup)
        end

        it 'Signup::ContractSignupDomain.signupが呼ばれること' do
          SignupService.signup(token, signups)
          expect(Signup::ContractSignupDomain).to have_received(:signup)
        end
      end

      context 'contract権限を持たないuserのtokenが渡された場合' do
        let!(:user) { create(:user, activated: true) }
        let!(:payload) do
          {
            sub: user.id,
            type: 'api'
          }
        end
        let!(:auth) { generate_token(payload:) }
        let!(:token) { auth.token }

        before do
          allow(Signup::UserSignupDomain).to receive(:signup)
        end

        it 'Signup::UserSignupDomain.signupが呼ばれること' do
          SignupService.signup(token, signups)
          expect(Signup::UserSignupDomain).to have_received(:signup)
        end
      end
    end
  end
end
