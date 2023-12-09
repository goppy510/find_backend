# frozen_string_literal: true

require 'rails_helper'

describe Api::UsersController, type: :request do
  include SessionModule

  describe ' GET /api/users/:user_id' do
    context '正常系' do
      context 'users権限を持つユーザーがリクエストした場合' do
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
        let!(:user_resource) { Resource.find_by(name: 'user') }
        let!(:permission) { create(:permission, user_id: user.id, resource_id: user_resource.id) }

        context '正しいパラメータを受け取った場合' do
          let!(:target_user) { create(:user, activated: true) }
          let!(:contract_membership) { create(:contract_membership, user_id: target_user.id, contract_id: contract.id) }
          let!(:params) do
            {
              user_id: target_user.id
            }
          end

          before do
            travel_to Time.zone.local(2023, 5, 10, 3, 0, 0)
            get "/api/users/#{target_user.id}", params:, headers: { 'Authorization' => "Bearer #{token}" }
          end

          it 'status_code: okを返すこと' do
            expect(response).to have_http_status(:ok)
          end

          it 'jsonであること' do
            expect(response.content_type).to eq('application/json; charset=utf-8')
          end

          it 'target_userの情報が返ってくること' do
            expect(JSON.parse(response.body)).to eq(
              {
                'id' => target_user.id,
                'email' => target_user.email,
                'activated' => target_user.activated,
                'created_at' => target_user.created_at.strftime('%Y-%m-%d %H:%M:%S'),
                'updated_at' => target_user.updated_at.strftime('%Y-%m-%d %H:%M:%S')
              }
            )
          end
        end
      end
    end

    context '異常系' do
      context 'user権限を持たないユーザーがリクエストした場合' do
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
        let!(:contract_resource) { Resource.find_by(name: 'contract') }
        let!(:permission) { create(:permission, user_id: user.id, resource_id: contract_resource.id) }
        let!(:target_user) { create(:user, activated: true) }
        let!(:contract_membership) { create(:contract_membership, user_id: target_user.id, contract_id: contract.id) }
        let!(:params) do
          {
            user_id: target_user.id
          }
        end

        before do
          travel_to Time.zone.local(2023, 5, 10, 3, 0, 0)
          get "/api/users/#{target_user.id}", params:, headers: { 'Authorization' => "Bearer #{token}" }
        end

        it 'status_code: 403を返すこと' do
          expect(response).to have_http_status(403)
        end

        it 'Contracts::ContractError::Forbiddenを返すこと' do
          expect(JSON.parse(response.body)['error']['code']).to eq('Contracts::ContractsError::Forbidden')
        end
      end

      context '既に削除されたユーザーをリクエストした場合' do
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
        let!(:user_resource) { Resource.find_by(name: 'user') }
        let!(:permission) { create(:permission, user_id: user.id, resource_id: user_resource.id) }
        let!(:target_user) { create(:user, activated: true) }
        let!(:contract_membership) { create(:contract_membership, user_id: target_user.id, contract_id: contract.id) }
        let!(:params) do
          {
            user_id: target_user.id
          }
        end

        before do
          travel_to Time.zone.local(2023, 5, 10, 3, 0, 0)
          target_user.destroy
          get "/api/users/#{target_user.id}", params:, headers: { 'Authorization' => "Bearer #{token}" }
        end

        it 'status_code: 404を返すこと' do
          expect(response).to have_http_status(404)
        end

        it 'not_foundを返すこと' do
          expect(JSON.parse(response.body)['error']['code']).to eq('not_found')
        end
      end
    end
  end

  describe ' GET /api/users' do
    context '正常系' do
      context 'users権限を持つユーザーがリクエストした場合' do
        let!(:user) { create(:user, activated: true) }
        let!(:other) { create(:user, activated: true) }
        let!(:contract) { create(:contract, user_id: user.id) }
        let!(:other_contract) { create(:contract, user_id: other.id) }
        let!(:payload) do
          {
            sub: user.id,
            type: 'api'
          }
        end
        let!(:auth) { generate_token(payload:) }
        let!(:token) { auth.token }
        let!(:user_resource) { Resource.find_by(name: 'user') }
        let!(:permission) { create(:permission, user_id: user.id, resource_id: user_resource.id) }

        context '正しいパラメータを受け取った場合' do
          let!(:target_user_1) { create(:user, activated: true) }
          let!(:target_user_2) { create(:user, activated: true) }
          let!(:target_user_3) { create(:user, activated: true) }
          let!(:contract_membership) do
            create(:contract_membership, user_id: target_user_1.id, contract_id: contract.id) 
            create(:contract_membership, user_id: target_user_3.id, contract_id: contract.id)
            create(:contract_membership, user_id: target_user_2.id, contract_id: other_contract.id)
          end

          before do
            travel_to Time.zone.local(2023, 5, 10, 3, 0, 0)
            get '/api/users', headers: { 'Authorization' => "Bearer #{token}" }
          end

          it 'status_code: okを返すこと' do
            expect(response).to have_http_status(:ok)
          end

          it 'jsonであること' do
            expect(response.content_type).to eq('application/json; charset=utf-8')
          end

          it 'target_user_1, target_user_3の情報が返ってくること' do
            expect(JSON.parse(response.body)).to eq(
              [
                {
                  'id' => target_user_1.id,
                  'email' => target_user_1.email,
                  'activated' => target_user_1.activated,
                  'created_at' => target_user_1.created_at.strftime('%Y-%m-%d %H:%M:%S'),
                  'updated_at' => target_user_1.updated_at.strftime('%Y-%m-%d %H:%M:%S')
                },
                {
                  'id' => target_user_3.id,
                  'email' => target_user_3.email,
                  'activated' => target_user_3.activated,
                  'created_at' => target_user_3.created_at.strftime('%Y-%m-%d %H:%M:%S'),
                  'updated_at' => target_user_3.updated_at.strftime('%Y-%m-%d %H:%M:%S')
                }
              ]
            )
          end
        end
      end
    end

    context '異常系' do
      context 'user権限を持たないユーザーがリクエストした場合' do
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
        let!(:contract_resource) { Resource.find_by(name: 'contract') }
        let!(:permission) { create(:permission, user_id: user.id, resource_id: contract_resource.id) }
        let!(:target_user) { create(:user, activated: true) }
        let!(:contract_membership) { create(:contract_membership, user_id: target_user.id, contract_id: contract.id) }

        before do
          travel_to Time.zone.local(2023, 5, 10, 3, 0, 0)
          get '/api/users', headers: { 'Authorization' => "Bearer #{token}" }
        end

        it 'status_code: 403を返すこと' do
          expect(response).to have_http_status(403)
        end

        it 'Contracts::ContractError::Forbiddenを返すこと' do
          expect(JSON.parse(response.body)['error']['code']).to eq('Contracts::ContractsError::Forbidden')
        end
      end
    end
  end

  describe ' DELETE /api/users/:user_id' do
    context '正常系' do
      context 'user権限を持つユーザーがリクエストした場合' do
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
        let!(:user_resource) { Resource.find_by(name: 'user') }
        let!(:permission) { create(:permission, user_id: user.id, resource_id: user_resource.id) }

        context '正しいパラメータを受け取った場合' do
          let!(:target_user) { create(:user, activated: true) }
          let!(:contract_membership) { create(:contract_membership, user_id: target_user.id, contract_id: contract.id) }
          let!(:params) do
            {
              user_id: target_user.id
            }
          end

          before do
            travel_to Time.zone.local(2023, 5, 10, 3, 0, 0)
            delete "/api/users/#{target_user.id}", params: params, headers: { 'Authorization' => "Bearer #{token}" }
          end

          it 'status_code: okを返すこと' do
            expect(response).to have_http_status(:ok)
          end

          it 'jsonであること' do
            expect(response.content_type).to eq('application/json; charset=utf-8')
          end

          it 'target_userが削除されること' do
            expect(User.find_by(id: target_user.id)).to eq(nil)
          end
        end
      end
    end

    context '異常系' do
      context 'user権限を持たないユーザーがリクエストした場合' do
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
        let!(:contract_resource) { Resource.find_by(name: 'contract') }
        let!(:permission) { create(:permission, user_id: user.id, resource_id: contract_resource.id) }
        let!(:target_user) { create(:user, activated: true) }
        let!(:contract_membership) { create(:contract_membership, user_id: target_user.id, contract_id: contract.id) }
        let!(:params) do
          {
            user_id: target_user.id
          }
        end

        before do
          travel_to Time.zone.local(2023, 5, 10, 3, 0, 0)
          get "/api/users/#{target_user.id}", params:, headers: { 'Authorization' => "Bearer #{token}" }
        end

        it 'status_code: 403を返すこと' do
          expect(response).to have_http_status(403)
        end

        it 'Contracts::ContractError::Forbiddenを返すこと' do
          expect(JSON.parse(response.body)['error']['code']).to eq('Contracts::ContractsError::Forbidden')
        end
      end

      context '既に削除されたユーザーをリクエストした場合' do
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
        let!(:user_resource) { Resource.find_by(name: 'user') }
        let!(:permission) { create(:permission, user_id: user.id, resource_id: user_resource.id) }
        let!(:target_user) { create(:user, activated: true) }
        let!(:contract_membership) { create(:contract_membership, user_id: target_user.id, contract_id: contract.id) }
        let!(:params) do
          {
            user_id: target_user.id
          }
        end

        before do
          travel_to Time.zone.local(2023, 5, 10, 3, 0, 0)
          target_user.destroy
          get "/api/users/#{target_user.id}", params:, headers: { 'Authorization' => "Bearer #{token}" }
        end

        it 'status_code: 404を返すこと' do
          expect(response).to have_http_status(404)
        end

        it 'not_foundを返すこと' do
          expect(JSON.parse(response.body)['error']['code']).to eq('not_found')
        end
      end
    end
  end
end
