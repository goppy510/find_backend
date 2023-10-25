# frozen_string_literal: true

require 'rails_helper'
require 'rspec-rails'
require 'faker'

describe Password::PasswordDomain do
  include SessionModule
  before do
    travel_to Time.zone.local(2023, 5, 10, 3, 0, 0)
    allow(ActivationMailService).to receive(:activation_email)
  end
  
  describe '#self.update' do
    context '正常系' do
      let!(:user) { create(:user, password: current_password, activated: true) }
      context '必要なすべてのパラメータを受け取った場合' do
        before do
          travel_to Time.zone.local(2023, 5, 10, 3, 0, 0)
        end
        let!(:current_password) { 'P@ssw0rd' }
        let!(:new_password) { 'H$lloW0rld' }
        it 'new_passwordに更新されること' do
          Password::PasswordDomain.update(user.id, current_password, new_password)
          actual = User.find(user.id)
          expect(actual.authenticate(new_password)).to be_truthy
        end
      end
    end

    context '異常系' do
      let!(:user) { create(:user, password: current_password, activated: true) }
      let!(:current_password) { 'P@ssw0rd' }
      let!(:new_password) { 'H$lloW0rld' }
      before do
        travel_to Time.zone.local(2023, 5, 10, 3, 0, 0)
      end

      context 'current_passwordがDBと不一致の場合' do
        it 'SecurityErrorがraiseされること' do
          expect { Password::PasswordDomain.update(user.id, 'dummy_P@ssw0rd', new_password) }
            .to raise_error(SecurityError)
        end
      end

      context 'tokenがない場合' do
        it 'ArgumentErrorがスローされること' do
          expect do
            Password::PasswordDomain.update(nil, current_password, new_password)
          end.to raise_error(ArgumentError, 'user_idがありません')
        end
      end

      context 'current_passwordがない場合' do
        it 'ArgumentErrorがスローされること' do
          expect do
            Password::PasswordDomain.update(user.id, nil, new_password)
          end.to raise_error(ArgumentError, 'current_passwordがありません')
        end
      end

      context 'new_passwordがない場合' do
        it 'ArgumentErrorがスローされること' do
          expect do
            Password::PasswordDomain.update(user.id, current_password, nil)
          end.to raise_error(ArgumentError, 'new_passwordがありません')
        end
      end
    end
  end
end
