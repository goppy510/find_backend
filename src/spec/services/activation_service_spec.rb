# frozen_string_literal: true

require 'rails_helper'
require 'rspec-rails'
require 'faker'

describe ActivationService do
  include SessionModule

  describe '#self.activate' do
    context '正常系' do
      let!(:user) { create(:user, activated: true) }
      let!(:payload) do
        {
          sub: user.id,
          type: 'api'
        }
      end
      let!(:auth) { generate_token(payload:) }
      let!(:token) { auth.token }

      context 'tokenが渡された場合' do
        before do
          allow(Activation::ActivationDomain).to receive(:activate)
        end

        it 'Activation::ActivationDomain.activateが呼ばれること' do
          ActivationService.activate(token)
          expect(Activation::ActivationDomain).to have_received(:activate)
        end
      end
    end
  end
end
