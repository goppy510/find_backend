#frozen_string_literal: true

require 'rails_helper'
require 'rspec-rails'
require 'faker'

describe Auth::AuthenticatorService  do
  describe '#new' do
    context '正常系' do
      context 'headerトークンのみを渡された場合' do
        let!(:header_token) { 'header_token' }
        it '@header_tokenに値が入ること' do
          service = Auth::AuthenticatorService.new(header_token: header_token)
          expect(service.instance_variable_get(:@header_token)).to eq(header_token)
          expect(service.instance_variable_get(:@cookie_token)).to be_nil
        end
      end

      context 'cookieトークンのみを渡された場合' do
        let!(:cookie_token) { 'cookie_token' }
        it '@cookie_tokenに値が入ること' do
          service = Auth::AuthenticatorService.new(cookie_token: cookie_token)
          expect(service.instance_variable_get(:@cookie_token)).to eq(cookie_token)
          expect(service.instance_variable_get(:@header_token)).to be_nil
        end
      end

      context 'headerトークン、cookieトークンの両方を渡された場合' do
        let!(:header_token) { 'header_token' }
        let!(:cookie_token) { 'cookie_token' }
        it '@header_token、@cookie_tokenに値が入ること' do
          service = Auth::AuthenticatorService.new(header_token: header_token, cookie_token: cookie_token)
          expect(service.instance_variable_get(:@cookie_token)).to eq(cookie_token)
          expect(service.instance_variable_get(:@header_token)).to eq(header_token)
        end
      end
    end
  end

  describe '#authenticate_user' do
    context '正常系' do
      before do
        travel_to Time.zone.local(2023, 05, 10, 3, 0, 0)
      end

      let!(:user1) { create(:user, activated: true) }
      let!(:user2) { create(:user, activated: true) }
      let!(:token) {  Auth::AuthTokenService.new(payload: { sub: user1.id, type: 'api' }).token }

      context '有効なtokenがヘッダーにあり、tokenに有効なuser.idがある場合' do
        it 'user_idとexpが返ってくること' do
          service = Auth::AuthenticatorService.new(header_token: token)
          res = service.authenticate_user
          expect(res[:user_id]).to eq(user1.id)
          expect(Time.at(res[:exp])).to eq(Time.zone.local(2023, 05, 24, 3, 0, 0))
        end
      end

      context '有効なtokenがcookieにあり、tokenに有効なuser.idがある場合' do
        it 'user_idとexpが返ってくること' do
          service = Auth::AuthenticatorService.new(cookie_token: token)
          res = service.authenticate_user
          expect(res[:user_id]).to eq(user1.id)
          expect(Time.at(res[:exp])).to eq(Time.zone.local(2023, 05, 24, 3, 0, 0))
        end
      end

      context '無効なtokenだった（userが見つからない）場合' do
        let!(:user1) { create(:user, activated: false) }
        let!(:user2) { create(:user, activated: true) }
        let!(:token) {  Auth::AuthTokenService.new(payload: { sub: user1.id, type: 'api' }).token }

        it 'nilが返ってくること' do
          service = Auth::AuthenticatorService.new(cookie_token: token)
          res = service.authenticate_user
          expect(res).to be_nil
        end
      end
    end
  end

  describe '#authenticate_user_not_activate' do
    context '正常系' do
      before do
        travel_to Time.zone.local(2023, 05, 10, 3, 0, 0)
      end

      let!(:user1) { create(:user, activated: false) }
      let!(:user2) { create(:user, activated: false) }
      let!(:token) {  Auth::AuthTokenService.new(payload: { sub: user1.id, type: 'activation' }).token }

      context '有効なtokenがヘッダーにあり、tokenに有効なuser.idがある場合' do
        it 'user_idとexpが返ってくること' do
          service = Auth::AuthenticatorService.new(header_token: token)
          res = service.authenticate_user_not_activate
          expect(res[:user_id]).to eq(user1.id)
          expect(Time.at(res[:exp])).to eq(Time.zone.local(2023, 05, 24, 3, 0, 0))
        end
      end

      context '無効なtokenだった（userが見つからない）場合' do
        let!(:user1) { create(:user, activated: true) }
        let!(:user2) { create(:user, activated: true) }
        let!(:token) {  Auth::AuthTokenService.new(payload: { sub: user1.id, type: 'activation' }).token }

        it 'nilが返ってくること' do
          service = Auth::AuthenticatorService.new(cookie_token: token)
          res = service.authenticate_user_not_activate
          expect(res).to be_nil
        end
      end
    end
  end
end
