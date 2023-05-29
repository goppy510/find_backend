#frozen_string_literal: true

require 'rails_helper'
require 'rspec-rails'
require 'faker'

describe LoginService do
  describe '#login' do
    context '正常系' do
      context '正しいメールアドレスとパスワードを受け取った場合' do
        before do
          travel_to Time.zone.local(2023, 05, 10, 3, 0, 0)
        end

        let!(:email) { Faker::Internet.email }
        let!(:password) { 'P@ssw0rd' }
        let!(:user) { create(:user, email: email, password: password, activated: true) }
        let!(:profile) { create(:profile, user_id: user.id) }

        it 'use.idとexpがレスポンスとして返ってくること' do
          service = LoginService.new(email, password)
          res = service.login
          expect(Time.at(res[:response][:exp])).to eq(Time.zone.local(2023, 05, 24, 3, 0, 0))
          expect(res[:response][:user_id]).to eq(user.id)
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
