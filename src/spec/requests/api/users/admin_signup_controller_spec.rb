# frozen_string_literal: true

require 'rails_helper'

describe Api::Users::AdminSignupController, type: :request do
  include SessionModule

  let!(:user) { create(:user, activated: true) }
  let!(:payload) do
    {
      sub: user.id,
      type: 'api'
    }
  end
  let!(:auth) { generate_token(payload:) }
  let!(:token) { auth.token }
  let!(:contract_resource) { Resource.find_by(name: 'contract') }
  let!(:permission) { create(:permission, user_id: user.id, resource_id: contract_resource.id) }

  describe 'POST /api/users/admin_signup' do
    context '正常系' do
      context '正しいパラメータを受け取った場合' do
        let!(:email) { Faker::Internet.email }
        let!(:password) { 'P@ssw0rd' }
        let!(:params) do
          {
            signups: {
              email:,
              password:
            }
          }
        end

        before do
          travel_to Time.zone.local(2023, 5, 10, 3, 0, 0)
          post '/api/users/admin_signup', params:, headers: { 'Authorization' => "Bearer #{token}" }
        end

        it 'status_code: okを返すこと' do
          expect(response).to have_http_status(:ok)
        end

        it 'statusがsuccessであること' do
          expect(JSON.parse(response.body)['status']).to eq('success')
        end

        it 'usersにemailが登録されていること' do
          user = User.find_by(email:)
          expect(user.email).to eq(email)
        end
      end
    end

    context '異常系' do
      context 'パラメータがなかった場合' do
        let!(:email) { Faker::Internet.email }
        let!(:password) { 'P@ssw0rd' }

        context 'emailがなかった場合' do
          let!(:params) do
            {
              signups: {
                email: nil,
                password:
              }
            }
          end
          before do
            post '/api/users/admin_signup', params:,  headers: { 'Authorization' => "Bearer #{token}" }
          end

          it 'status_code: 400を返すこと' do
            expect(response).to have_http_status(400)
          end

          it 'emailがありませんを返すこと' do
            expect(JSON.parse(response.body)['error']['code']).to eq('emailがありません')
          end
        end

        context 'passwordがなかった場合' do
          let!(:params) do
            {
              signups: {
                email:,
                password: nil
              }
            }
          end
          before do
            post '/api/users/admin_signup', params:, headers: { 'Authorization' => "Bearer #{token}" }
          end

          it 'status_code: 400を返すこと' do
            expect(response).to have_http_status(400)
          end

          it 'passwordがありませんを返すこと' do
            expect(JSON.parse(response.body)['error']['code']).to eq('passwordがありません')
          end
        end
      end

      context 'emailが重複していた場合' do
        let!(:email) { Faker::Internet.email }
        let!(:password) { 'P@ssw0rd' }
        let!(:params) do
          {
            signups: {
              email:,
              password:
            }
          }
        end
        let!(:user_1) { create(:user, email:) }

        before do
          post '/api/users/admin_signup', params:, headers: { 'Authorization' => "Bearer #{token}" }
        end

        it 'status_code: 409を返すこと' do
          expect(response).to have_http_status(409)
        end

        it 'AdminSignupService::DuplicateEntryを返すこと' do
          expect(JSON.parse(response.body)['error']['code']).to eq('AdminSignupService::DuplicateEntry')
        end
      end

      context 'emailのフォーマットが不正な場合' do
        let!(:email) { 'test' }
        let!(:password) { 'P@ssw0rd' }
        let!(:params) do
          {
            signups: {
              email:,
              password:
            }
          }
        end

        before do
          post '/api/users/admin_signup', params:, headers: { 'Authorization' => "Bearer #{token}" }
        end

        it 'status_code: 422を返すこと' do
          expect(response).to have_http_status(422)
        end

        it 'AdminSignupService::EmailFormatErrorを返すこと' do
          expect(JSON.parse(response.body)['error']['code']).to eq('AdminSignupService::EmailFormatError')
        end
      end

      context 'passwordのフォーマットが不正な場合' do
        let!(:email) { Faker::Internet.email }
        let!(:password) { 'test' }
        let!(:params) do
          {
            signups: {
              email:,
              password:
            }
          }
        end

        before do
          post '/api/users/admin_signup', params:, headers: { 'Authorization' => "Bearer #{token}" }
        end

        it 'status_code: 422を返すこと' do
          expect(response).to have_http_status(422)
        end

        it 'AdminSignupService::PasswordFormatErrorを返すこと' do
          expect(JSON.parse(response.body)['error']['code']).to eq('AdminSignupService::PasswordFormatError')
        end
      end
    end
  end
end
