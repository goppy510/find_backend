#frozen_string_literal: true

require 'rails_helper'
require 'rspec-rails'
require 'faker'

describe ActivationService do
  describe '#account' do
    context '正常系' do
      context '有効なトークンを受け取った場合' do
        before do
          travel_to Time.zone.local(2023, 05, 10, 3, 0, 0)
        end

        let!(:user) { create(:user) }
        let!(:registration_token) { create(:registration_token, user_id: user.id, token: 'token', expires_at: Time.zone.local(2023, 05, 10, 4, 0, 0)) }

        it 'usersのactivatedがtrueになること' do
          service = ActivationService.new(registration_token.token)
          service.activate
          expect(User.find(user.id).activated).to be_truthy
        end

        it 'registration_tokensの該当レコードが物理削除されること' do
          service = ActivationService.new(registration_token.token)
          service.activate
          expect(RegistrationToken.find_by(user_id: user.id)).to be_nil
        end
      end
    end

    context '異常系' do
      before do
        travel_to Time.zone.local(2023, 05, 10, 3, 0, 0)
      end

      context 'tokenがなかった場合' do
        it 'ArgumentErrorが発生すること' do
          expect{ ActivationService.new(nil) }.to raise_error(ArgumentError, 'tokenがありません')
        end
      end

      context 'registration_tokensのレコードがない場合' do
        it 'ActiveRecord::RecordNotFoundが発生すること' do
          expect{ ActivationService.new('hoge') }.to raise_error(ActiveRecord::RecordNotFound, 'registration_tokenがありません')
        end
      end

      context 'tokenの有効期限が切れている場合' do
        let!(:user) { create(:user) }
        let!(:registration_token) { create(:registration_token, user_id: user.id, token: 'token', expires_at: Time.zone.local(2023, 05, 10, 2, 0, 0)) }

        it 'ExpiredTokenErrorが発生すること' do
          expect{ ActivationService.new(registration_token.token) }.to raise_error(ExpiredTokenError, 'tokenの有効期限が切れています')
        end
      end
    end
  end
end
