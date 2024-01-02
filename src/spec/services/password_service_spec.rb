# frozen_string_literal: true

require 'rails_helper'
require 'rspec-rails'
require 'faker'

describe PasswordService do
  include SessionModule

  describe '#self.update' do
    context '正常系' do
      context '必要なすべてのパラメータを受け取った場合' do
        before do
          travel_to Time.zone.local(2023, 5, 10, 3, 0, 0)
          allow(Password::PasswordDomain).to receive(:update)
        end

        let!(:user) { create(:user, password: current_password, activated: true) }
        let!(:current_password) { 'P@ssw0rd' }
        let!(:new_password) { 'H$lloW0rld' }

        let!(:user) { create(:user, password: current_password, activated: true) }
        let!(:payload) do
          {
            sub: user.id,
            type: 'api'
          }
        end
        let!(:auth) { generate_token(payload:) }
        let!(:token) { auth.token }

        it 'Password::PasswordDomain.updateが呼ばれること' do
          PasswordService.update(token, current_password, new_password)
          expect(Password::PasswordDomain).to have_received(:update).with(user.id, current_password, new_password)
        end
      end
    end

    context '異常系' do
      before do
        travel_to Time.zone.local(2023, 5, 10, 3, 0, 0)
        allow(Password::PasswordDomain).to receive(:update)
      end

      let!(:user) { create(:user, password: current_password, activated: true) }
      let!(:current_password) { 'P@ssw0rd' }
      let!(:new_password) { 'H$lloW0rld' }
      let!(:payload) do
        {
          sub: user.id,
          type: 'api'
        }
      end
      let!(:auth) { generate_token(payload:) }
      let!(:token) { auth.token }

      context 'tokenがない場合' do
        it 'ArgumentErrorがスローされること' do
          expect do
            PasswordService.update(nil, current_password, new_password)
          end.to raise_error(ArgumentError, 'tokenがありません')
        end
      end

      context 'current_passwordがない場合' do
        it 'ArgumentErrorがスローされること' do
          expect do
            PasswordService.update(token, nil, new_password)
          end.to raise_error(ArgumentError, 'current_passwordがありません')
        end
      end

      context 'new_passwordがない場合' do
        it 'ArgumentErrorがスローされること' do
          expect do
            PasswordService.update(token, current_password, nil)
          end.to raise_error(ArgumentError, 'new_passwordがありません')
        end
      end

      context 'tokenが不正な場合' do
        it 'Password::PasswordError::Unauthorizedがスローされること' do
          expect do
            PasswordService.update('dummy_token', current_password, new_password)
          end.to raise_error(Password::PasswordError::Unauthorized)
        end
      end
    end
  end
end
