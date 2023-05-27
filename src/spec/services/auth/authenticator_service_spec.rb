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

      # delete_cookie, unauthorized_userをまとめてテスト
      # cookiesメソッドはコントローラーのテストじゃないとできないのでこのテストでは実施しない
      context '無効なtokenだった（userが見つからない）場合' do
        let!(:service_mock) { Auth::AuthenticatorService.new }
        before do
          allow(service_mock).to receive(:current_user).and_return(nil)
          # 左辺がfalseだと右辺呼ばれないのでtrueを返して右辺が呼ばれるようにしているｓ
          allow(service_mock).to receive(:head_unauthorized).and_return(true)
          allow(service_mock).to receive(:delete_cookie)
        end

        it 'delete_cookieメソッドが呼ばれること' do
          service_mock.authenticate_user
          expect(service_mock).to have_received(:delete_cookie)
        end
      end
    end
  end
end
