# frozen_string_literal: true

require 'rails_helper'

describe Api::Users::PasswordController, type: :request do
  include SessionModule

  describe 'PUT /api/users/password' do
    context '正常系' do
      context 'contract権限を持つユーザーがリクエストした場合' do
        let!(:current_password) { 'P@ssw0rd' }
        let!(:user) { create(:user, activated: true, password: current_password) }
        let!(:payload) do
          {
            sub: user.id,
            type: 'api'
          }
        end
        let!(:auth) { generate_token(payload:) }
        let!(:token) { auth.token }

        context '正しいパラメータを受け取った場合' do
          let!(:new_password) { 'P@ssw0rd2' }
          let!(:params) do
            {
              password: {
                current_password: current_password,
                new_password: new_password
              }
            }
          end

          before do
            travel_to Time.zone.local(2023, 5, 10, 3, 0, 0)
            put "/api/users/password/#{1}", params:, headers: { 'Authorization' => "Bearer #{token}" }
          end

          it 'status_code: okを返すこと' do
            expect(response).to have_http_status(:ok)
          end

          it 'statusがsuccessであること' do
            expect(JSON.parse(response.body)['status']).to eq('success')
          end

          it 'passwordが変更されていること' do
            actual = User.find_by(id: user.id)
            expect(actual.authenticate(new_password)).to be_truthy
          end
        end
      end
    end

    context '異常系' do
      context 'tokenが不正な場合' do
        let!(:current_password) { 'P@ssw0rd' }
        let!(:user) { create(:user, activated: true, password: current_password) }
        let!(:payload) do
          {
            sub: 9999,
            type: 'api'
          }
        end
        let!(:auth) { generate_token(payload:) }
        let!(:token) { auth.token }

        context '正しいパラメータを受け取った場合' do
          let!(:new_password) { 'P@ssw0rd2' }
          let!(:params) do
            {
              password: {
                current_password: current_password,
                new_password: new_password
              }
            }
          end

          before do
            travel_to Time.zone.local(2023, 5, 10, 3, 0, 0)
            put "/api/users/password/#{1}", params:, headers: { 'Authorization' => "Bearer #{token}" }
          end

          it 'status_code: unauthorizedを返すこと' do
            expect(response).to have_http_status(:unauthorized)
          end

          it 'APassword::PasswordError::Unauthorizedを返すこと' do
            expect(JSON.parse(response.body)['error']['code']).to eq('Password::PasswordError::Unauthorized')
          end

          it 'passwordが変更されていないこと' do
            actual = User.find_by(id: user.id)
            expect(actual.authenticate(new_password)).to be_falsey
          end
        end
      end
    end
  end
end
