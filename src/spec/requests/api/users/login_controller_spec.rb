# frozen_string_literal: true

require 'rails_helper'

describe Api::Users::LoginController, type: :request do
  include SessionModule

  describe 'POST /api/users/login' do
    context '正常系' do
      context '正しいパラメータを受け取った場合' do
        let!(:email) { Faker::Internet.email }
        let!(:password) { 'P@ssw0rd' }
        let!(:user1) { create(:user, email:, password:, activated: true) }
        let!(:payload) do
          {
            sub: user1.id,
            type: 'api'
          }
        end
        let!(:auth) { generate_token(payload:) }
        let!(:token) { auth.token }
        let!(:expires) { Time.zone.at(auth.payload[:exp]).strftime('%Y-%m-%dT%H:%M:%S.%LZ') }
        let!(:valid_params) do
          {
            logins: {
              email:,
              password:
            }
          }
        end

        before do
          post '/api/users/login', params: valid_params
        end

        it 'status_code: okを返すこと' do
          expect(response).to have_http_status(:ok)
        end

        let!(:expected_response) do
          {
            'token' => token,
            'expires' => expires,
            'user_id' => user1.id
          }
        end
        it 'responseに当該のtokenとexpが記載されていること' do
          expect(JSON.parse(response.body)).to eq(expected_response)
        end
      end
    end
  end
end
