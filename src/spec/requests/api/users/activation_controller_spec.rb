# frozen_string_literal: true

require 'rails_helper'

describe Api::Users::ActivationController, type: :request do
  include ActionController::Cookies
  include SessionModule

  describe 'POST /api/users/activation' do
    context '正常系' do
      context '正しいtokenを受け取った場合' do
        let!(:email) { Faker::Internet.email }
        let!(:password) { 'P@ssw0rd' }
        let!(:user) { create(:user, email:, password:) }
        let!(:payload) do
          {
            sub: user.id,
            type: 'activation'
          }
        end
        let!(:auth) { generate_token(lifetime: Auth.token_signup_lifetime, payload:) }
        let!(:token) { auth.token }

        before do
          travel_to Time.zone.local(2023, 5, 10, 3, 0, 0)
          post '/api/users/activation', headers: { 'Authorization' => "Bearer #{token}" }
        end

        it 'status_code: okを返すこと' do
          expect(response).to have_http_status(:ok)
        end

        it 'statusがsuccessであること' do
          expect(JSON.parse(response.body)['status']).to eq('success')
        end

        it 'userのactivatedがtrueになっていること' do
          user = User.find_by(email:)
          expect(user.activated).to be_truthy
        end
      end
    end

    context '異常系' do
      context 'tokenがなかった場合' do
        let!(:email) { Faker::Internet.email }
        let!(:password) { 'P@ssw0rd' }
        let!(:user) { create(:user, email:, password:) }

        before do
          travel_to Time.zone.local(2023, 5, 10, 3, 0, 0)
          post '/api/users/activation', headers: { 'Authorization' => '' }
        end

        it 'status_code: 400を返すこと' do
          expect(response).to have_http_status(400)
        end

        it 'codeがinvalid_parameterであること' do
          expect(JSON.parse(response.body)['error']['code']).to eq('invalid_parameter')
        end

        it 'userのactivatedがfalseのままであること' do
          user = User.find_by(email:)
          expect(user.activated).to be_falsy
        end
      end

      context '不正なtokenだった場合' do
        let!(:email) { Faker::Internet.email }
        let!(:password) { 'P@ssw0rd' }
        let!(:user) { create(:user, email:, password:) }
        let!(:invalid_token) do
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9
            .eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ
              .SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c'
        end

        before do
          travel_to Time.zone.local(2023, 5, 10, 3, 0, 0)
          post '/api/users/activation', headers: { 'Authorization' => "Bearer #{invalid_token}" }
        end

        it 'status_code: 401を返すこと' do
          expect(response).to have_http_status(401)
        end

        it 'codeがActionController::Unahuthorizedであること' do
          expect(JSON.parse(response.body)['error']['code']).to eq('ActionController::Unauthorized')
        end

        it 'userのactivatedがfalseのままであること' do
          user = User.find_by(email:)
          expect(user.activated).to be_falsy
        end
      end

      context 'tokenは正しいが該当するuserがなかった場合' do
        let!(:email) { Faker::Internet.email }
        let!(:password) { 'P@ssw0rd' }
        let!(:user) { create(:user, email:, password:) }
        let!(:payload) do
          {
            sub: 999,
            type: 'activation'
          }
        end
        let!(:auth) { generate_token(lifetime: Auth.token_signup_lifetime, payload:) }
        let!(:token) { auth.token }

        before do
          travel_to Time.zone.local(2023, 5, 10, 3, 0, 0)
          post '/api/users/activation', headers: { 'Authorization' => "Bearer #{token}" }
        end

        it 'status_code: 401を返すこと' do
          expect(response).to have_http_status(401)
        end

        it 'codeがActionController::Unauthorizedであること' do
          expect(JSON.parse(response.body)['error']['code']).to eq('ActionController::Unauthorized')
        end

        it 'userのactivatedがfalseのままであること' do
          user = User.find_by(email:)
          expect(user.activated).to be_falsy
        end
      end

      context 'tokenは正しいが該当するactivate済みのユーザーだった場合' do
        let!(:email) { Faker::Internet.email }
        let!(:password) { 'P@ssw0rd' }
        let!(:user) { create(:user, email:, password:, activated: true) }
        let!(:payload) do
          {
            sub: user.id,
            type: 'activation'
          }
        end
        let!(:auth) { generate_token(lifetime: Auth.token_signup_lifetime, payload:) }
        let!(:token) { auth.token }

        before do
          travel_to Time.zone.local(2023, 5, 10, 3, 0, 0)
          post '/api/users/activation', headers: { 'Authorization' => "Bearer #{token}" }
        end

        it 'status_code: 401を返すこと' do
          expect(response).to have_http_status(401)
        end

        it 'codeがActionController::Unauthorizedであること' do
          expect(JSON.parse(response.body)['error']['code']).to eq('ActionController::Unauthorized')
        end
      end
    end
  end
end
