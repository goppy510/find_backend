#frozen_string_literal: true

require 'rails_helper'
require 'rspec-rails'
require 'faker'

describe Auth::AuthenticatorService  do
  describe '#authenticate_user' do
    context '正常系' do
      before do
        travel_to Time.zone.local(2023, 05, 10, 3, 0, 0)
      end

      let!(:user1) { create(:user) }
      let!(:user2) { create(:user) }
      let!(:token) {  Auth::AuthTokenService.new(payload: { sub: user1.id }).token }
      let!(:service) { Auth::AuthenticatorService.new }

      context '有効なtokenがヘッダーにあり、tokenに有効なuser.idがある場合' do
        before do
          allow(service).to receive(:token_from_request_headers).and_return(token)
        end

        it '正しいuserオブジェクトが返ってくること' do
          actual_user = service.authenticate_user
          expect(actual_user[:user_id]).to eq(user1.id)
        end
      end

      context '有効なtokenがcookieにあり、tokenに有効なuser.idがある場合' do
        before do
          allow(service).to receive(:token_from_request_headers).and_return(nil)
          allow(service).to receive(:token_from_cookies).and_return(token)
        end

        it '正しいuserオブジェクトが返ってくること' do
          actual_user = service.authenticate_user
          expect(actual_user[:user_id]).to eq(user1.id)
        end
      end
    end
  end

  describe '#delete_cookie' do
    context '正常系' do
      before do
        travel_to Time.zone.local(2023, 05, 10, 3, 0, 0)
      end

      let!(:user1) { create(:user) }
      let!(:user2) { create(:user) }
      let!(:token) { user1.to_token }

      context 'usersにレコードがあり、かつ、tokenが有効な場合' do
        it 'user.idがsubのvalueと一致すること' do
          service = Auth::AuthTokenService.new(token: token)
          actual_user = service.entity_for_user
          expect(actual_user.id).to eq user1.id
        end
      end
    end
  end
end
