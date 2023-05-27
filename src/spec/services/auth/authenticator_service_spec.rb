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

        let(:headers) { { 'Authorization' => "Bearer #{token}" } }
        let(:request) { double('request', headers: headers) }

        it '正しいuserオブジェクトが返ってくること' do
          actual_user = service.authenticate_user
          expect(actual_user[:user_id]).to eq(user1.id)
        end
      end

      context '有効なtokenがcookieにあり、tokenに有効なuser.idがある場合' do
        before do
          cookies = { token_access_key: token }
          request = double('request', cookies: cookies)
          allow(service).to receive(:request).and_return(request)
          allow(service).to receive(:token_from_request_headers).and_return(nil)
        end

        let!(:service) { Auth::AuthenticatorService.new }

        it '正しいuserオブジェクトが返ってくること' do
          actual_user = service.authenticate_user

          expect(actual_user.id).to eq(user1.id)
          expect(actual_user.email).to eq(user1.email)
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
