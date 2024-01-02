# frozen_string_literal: true

require 'rails_helper'

describe Api::Users::SignupController, type: :request do
  include SessionModule

  describe 'POST /api/users/signup' do
    context '正常系' do
      context 'contract権限を持つユーザーがリクエストした場合' do
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
            post '/api/users/signup', params:, headers: { 'Authorization' => "Bearer #{token}" }
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

      context 'user権限を持つユーザーがリクエストした場合' do
        let!(:user) { create(:user, activated: true) }
        let!(:contract) { create(:contract, user_id: user.id) }
        let!(:user_resource) { Resource.find_by(name: 'user') }
        let!(:permission) { create(:permission, user_id: user.id, resource_id: user_resource.id) }
        let!(:payload) do
          {
            sub: user.id,
            type: 'api'
          }
        end
        let!(:auth) { generate_token(payload:) }
        let!(:token) { auth.token }

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
            allow(ActivationMailService).to receive(:activation_email)
            post '/api/users/signup', params:, headers: { 'Authorization' => "Bearer #{token}" }
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
                password: password
              }
            }
          end
          let!(:user) { create(:user, email:, activated: true) }
          let!(:contract) { create(:contract, user_id: user.id) }
          let!(:user_resource) { Resource.find_by(name: 'user') }
          let!(:permission) { create(:permission, user_id: user.id, resource_id: user_resource.id) }
          let!(:payload) do
            {
              sub: user.id,
              type: 'api'
            }
          end
          let!(:auth) { generate_token(payload:) }
          let!(:token) { auth.token }

          before do
            post '/api/users/signup', params:, headers: { 'Authorization' => "Bearer #{token}" }
          end

          it 'status_code: 400を返すこと' do
            expect(response).to have_http_status(400)
          end

          it 'user_idがありませんを返すこと' do
            expect(JSON.parse(response.body)['error']['code']).to eq('emailがありません')
          end
        end

        context 'passwordがなかった場合' do
          let!(:params) do
            {
              signups: {
                email: email,
                password: nil
              }
            }
          end
          let!(:user) { create(:user, email:, activated: true) }
          let!(:contract) { create(:contract, user_id: user.id) }
          let!(:user_resource) { Resource.find_by(name: 'user') }
          let!(:permission) { create(:permission, user_id: user.id, resource_id: user_resource.id) }
          let!(:payload) do
            {
              sub: user.id,
              type: 'api'
            }
          end
          let!(:auth) { generate_token(payload:) }
          let!(:token) { auth.token }

          before do
            post '/api/users/signup', params:, headers: { 'Authorization' => "Bearer #{token}" }
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
        let!(:user) { create(:user, email:, activated: true) }
        let!(:contract) { create(:contract, user_id: user.id) }
        let!(:user_resource) { Resource.find_by(name: 'user') }
        let!(:permission) { create(:permission, user_id: user.id, resource_id: user_resource.id) }
        let!(:payload) do
          {
            sub: user.id,
            type: 'api'
          }
        end
        let!(:auth) { generate_token(payload:) }
        let!(:token) { auth.token }

        before do
          post '/api/users/signup', params:, headers: { 'Authorization' => "Bearer #{token}" }
        end

        it 'status_code: 409を返すこと' do
          expect(response).to have_http_status(409)
        end

        it 'SignupService::DuplicateEntryを返すこと' do
          expect(JSON.parse(response.body)['error']['code']).to eq('Signup::SignupError::DuplicateEntry')
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
        let!(:user) { create(:user, activated: true) }
        let!(:contract) { create(:contract, user_id: user.id) }
        let!(:user_resource) { Resource.find_by(name: 'user') }
        let!(:permission) { create(:permission, user_id: user.id, resource_id: user_resource.id) }
        let!(:payload) do
          {
            sub: user.id,
            type: 'api'
          }
        end
        let!(:auth) { generate_token(payload:) }
        let!(:token) { auth.token }

        before do
          post '/api/users/signup', params:, headers: { 'Authorization' => "Bearer #{token}" }
        end

        it 'status_code: 422を返すこと' do
          expect(response).to have_http_status(422)
        end

        it 'SignupService::EmailFormatErrorを返すこと' do
          expect(JSON.parse(response.body)['error']['code']).to eq('Signup::SignupError::EmailFormatError')
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
        let!(:user) { create(:user, activated: true) }
        let!(:contract) { create(:contract, user_id: user.id) }
        let!(:user_resource) { Resource.find_by(name: 'user') }
        let!(:permission) { create(:permission, user_id: user.id, resource_id: user_resource.id) }
        let!(:payload) do
          {
            sub: user.id,
            type: 'api'
          }
        end
        let!(:auth) { generate_token(payload:) }
        let!(:token) { auth.token }

        before do
          post '/api/users/signup', params:, headers: { 'Authorization' => "Bearer #{token}" }
        end

        it 'status_code: 422を返すこと' do
          expect(response).to have_http_status(422)
        end

        it 'SignupService::PasswordFormatErrorを返すこと' do
          expect(JSON.parse(response.body)['error']['code']).to eq('Signup::SignupError::PasswordFormatError')
        end
      end

      context 'userの登録上限に達した場合' do
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
        let!(:user) { create(:user, activated: true) }
        let!(:already_user) { create(:user, activated: true) }
        let!(:contract) { create(:contract, user_id: user.id, max_member_count: 1) }
        let!(:contract_membership) { create(:contract_membership, contract_id: contract.id, user_id: already_user.id) }
        let!(:user_resource) { Resource.find_by(name: 'user') }
        let!(:permission) { create(:permission, user_id: user.id, resource_id: user_resource.id) }
        let!(:payload) do
          {
            sub: user.id,
            type: 'api'
          }
        end
        let!(:auth) { generate_token(payload:) }
        let!(:token) { auth.token }

        before do
          allow(ActivationMailService).to receive(:activation_email)
          allow(User).to receive(:count).and_return(100)
          post '/api/users/signup', params:, headers: { 'Authorization' => "Bearer #{token}" }
        end

        it 'status_code: 403を返すこと' do
          expect(response).to have_http_status(403)
        end

        it 'SignupService::RecordLimitExceededを返すこと' do
          expect(JSON.parse(response.body)['error']['code']).to eq('Signup::SignupError::RecordLimitExceeded')
        end
      end

      context 'contract, userの権限がない場合' do
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
        let!(:user) { create(:user, activated: true) }
        let!(:contract) { create(:contract, user_id: user.id) }
        let!(:payload) do
          {
            sub: user.id,
            type: 'api'
          }
        end
        let!(:auth) { generate_token(payload:) }
        let!(:token) { auth.token }

        before do
          allow(ActivationMailService).to receive(:activation_email)
          post '/api/users/signup', params:, headers: { 'Authorization' => "Bearer #{token}" }
        end

        it 'status_code: 403を返すこと' do
          expect(response).to have_http_status(403)
        end

        it 'SignupService::Forbiddenを返すこと' do
          expect(JSON.parse(response.body)['error']['code']).to eq('Signup::SignupError::Forbidden')
        end
      end
    end
  end
end
