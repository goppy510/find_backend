spec/requests/api/contract_controller_spec.rb
# frozen_string_literal: true

require 'rails_helper'

describe Api::ContractController, type: :request do
  include SessionModule

  describe ' POST /api/contracts' do
    let!(:user) { create(:user, activated: true) }
    let!(:target_user) { create(:user, activated: true) }
    let!(:payload) do
      {
        sub: user.id,
        type: 'api'
      }
    end
    let!(:auth) { generate_token(payload:) }
    let!(:token) { auth.token }
    let!(:permission) { create(:permission, user_id: user.id, resource_id: resource.id) }
    context '正常系' do
      context 'contract権限を持つユーザーがリクエストした場合' do
        let!(:resource) { Resource.find_by(name: 'contract') }
        context '正しいパラメータを受け取った場合' do
          let!(:params) do
            {
              user_id: target_user.id,
              max_member_count: 10
            }
          end
          before do
            travel_to Time.zone.local(2023, 5, 10, 3, 0, 0)
            post '/api/contracts', params: params, headers: { 'Authorization' => "Bearer #{token}" }
          end
          it 'status_code: okを返すこと' do
            expect(response).to have_http_status(:ok)
          end
          it 'jsonであること' do
            expect(response.content_type).to eq('application/json; charset=utf-8')
          end
          it 'target_userがcontractsに登録されていること' do
            contract = Contract.find_by(user_id: target_user.id)
            expect(contract).to be_present
            expect(contract.max_member_count).to eq(10)
          end
        end
      end
    end
    context '異常系' do
      context 'contract権限を持たないユーザーがリクエストした場合' do
        let!(:resource) { Resource.find_by(name: 'user') }
        context '正しいパラメータを受け取った場合' do
          let!(:params) do
            {
              user_id: target_user.id,
              max_member_count: 10
            }
          end
          before do
            travel_to Time.zone.local(2023, 5, 10, 3, 0, 0)
            post '/api/contracts', params: params, headers: { 'Authorization' => "Bearer #{token}" }
          end
          it 'status_code: 403を返すこと' do
            expect(response).to have_http_status(403)
          end
          it 'Contracts::ContractsError::Forbiddenを返すこと' do
            expect(JSON.parse(response.body)['error']['code']).to eq('Contracts::ContractsError::Forbidden')
          end
        end
      end
      context '既に契約済みのユーザーをリクエストした場合' do
        let!(:contract) { create(:contract, user_id: target_user.id) }
        let!(:resource) { Resource.find_by(name: 'contract') }
        context '正しいパラメータを受け取った場合' do
          let!(:params) do
            {
              user_id: target_user.id,
              max_member_count: 10
            }
          end
          before do
            travel_to Time.zone.local(2023, 5, 10, 3, 0, 0)
            post '/api/contracts', params: params, headers: { 'Authorization' => "Bearer #{token}" }
          end
          it 'status_code: 400を返すこと' do
            expect(response).to have_http_status(400)
          end
          it 'ActionController::BadRequestを返すこと' do
            expect(JSON.parse(response.body)['error']['code']).to eq('ActionController::BadRequest')
          end
        end
      end
    end
  end

  describe ' GET /api/contracts/:user_id' do
    let!(:user) { create(:user, activated: true) }
    let!(:target_user) { create(:user, activated: true) }
    let!(:contract) { create(:contract, user_id: target_user.id) }
    let!(:payload) do
      {
        sub: user.id,
        type: 'api'
      }
    end
    let!(:auth) { generate_token(payload:) }
    let!(:token) { auth.token }
    let!(:permission) { create(:permission, user_id: user.id, resource_id: resource.id) }
    let!(:params) do
      {
        user_id: target_user.id
      }
    end
    context '正常系' do
      context 'contract権限を持つユーザーがリクエストした場合' do
        let!(:resource) { Resource.find_by(name: 'contract') }
        context '正しいパラメータを受け取った場合' do
          before do
            travel_to Time.zone.local(2023, 5, 10, 3, 0, 0)
            get "/api/contracts/#{target_user.id}", params: params, headers: { 'Authorization' => "Bearer #{token}" }
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
                'user_id' => target_user.id,
                'email' => target_user.email,
                'activated' => target_user.activated,
                'contract_id' => contract.id,
                'max_member_count' => contract.max_member_count,
                'created_at' => contract.created_at.strftime('%Y-%m-%d %H:%M:%S'),
                'updated_at' => contract.updated_at.strftime('%Y-%m-%d %H:%M:%S')
              }
            )
          end
        end
      end
    end
    context '異常系' do
      context 'user権限を持たないユーザーがリクエストした場合' do
        let!(:resource) { Resource.find_by(name: 'user') }
        before do
          travel_to Time.zone.local(2023, 5, 10, 3, 0, 0)
          get "/api/contracts/#{target_user.id}", params:, headers: { 'Authorization' => "Bearer #{token}" }
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

  describe ' GET /api/contracts' do
    let!(:user) { create(:user, activated: true) }
    let!(:payload) do
      {
        sub: user.id,
        type: 'api'
      }
    end
    let!(:auth) { generate_token(payload:) }
    let!(:token) { auth.token }
    let!(:permission) { create(:permission, user_id: user.id, resource_id: resource.id) }
    let!(:target_user_1) { create(:user, activated: true) }
    let!(:target_user_2) { create(:user, activated: true) }
    let!(:contract) do
      create(:contract, id: 1, user_id: target_user_1.id) 
      create(:contract, id: 2, user_id: target_user_2.id, max_member_count: 20)
    end
    context '正常系' do
      let!(:resource) { Resource.find_by(name: 'contract') }
      context 'contract権限を持つユーザーがリクエストした場合' do
        context '正しいパラメータを受け取った場合' do
          before do
            travel_to Time.zone.local(2023, 5, 10, 3, 0, 0)
            get '/api/contracts', headers: { 'Authorization' => "Bearer #{token}" }
          end
          it 'status_code: okを返すこと' do
            expect(response).to have_http_status(:ok)
          end
          it 'jsonであること' do
            expect(response.content_type).to eq('application/json; charset=utf-8')
          end
          it 'target_user_1, target_user_2の情報が返ってくること' do
            contract_1 = Contract.find_by(user_id: target_user_1.id)
            contract_2 = Contract.find_by(user_id: target_user_2.id)
            expect(JSON.parse(response.body)).to eq(
              [
                {
                  'user_id' => target_user_1.id,
                  'email' => target_user_1.email,
                  'activated' => target_user_1.activated,
                  'contract_id' => 1,
                  'max_member_count' => 5,
                  'created_at' => contract_1.created_at.strftime('%Y-%m-%d %H:%M:%S'),
                  'updated_at' => contract_1.updated_at.strftime('%Y-%m-%d %H:%M:%S')
                },
                {
                  'user_id' => target_user_2.id,
                  'email' => target_user_2.email,
                  'activated' => target_user_2.activated,
                  'contract_id' => 2,
                  'max_member_count' => 20,
                  'created_at' => contract_2.created_at.strftime('%Y-%m-%d %H:%M:%S'),
                  'updated_at' => contract_2.updated_at.strftime('%Y-%m-%d %H:%M:%S')
                }
              ]
            )
          end
        end
      end
    end
    context '異常系' do
      context 'contract権限を持たないユーザーがリクエストした場合' do
        let!(:resource) { Resource.find_by(name: 'user') }
        before do
          travel_to Time.zone.local(2023, 5, 10, 3, 0, 0)
          get '/api/contracts', headers: { 'Authorization' => "Bearer #{token}" }
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

  describe ' PUT /api/contracts/:user_id' do
    let!(:user) { create(:user, activated: true) }
    let!(:target_user) { create(:user, activated: true) }
    let!(:contract) { create(:contract, user_id: target_user.id) }
    let!(:payload) do
      {
        sub: user.id,
        type: 'api'
      }
    end
    let!(:auth) { generate_token(payload:) }
    let!(:token) { auth.token }
    let!(:permission) { create(:permission, user_id: user.id, resource_id: resource.id) }
    context '正常系' do
      context 'contract権限を持つユーザーがリクエストした場合' do
        let!(:resource) { Resource.find_by(name: 'contract') }
        context '正しいパラメータを受け取った場合' do
          let!(:params) do
            {
              user_id: target_user.id,
              max_member_count: 10
            }
          end
          before do
            travel_to Time.zone.local(2023, 5, 10, 3, 0, 0)
            put "/api/contracts/#{target_user.id}", params: params, headers: { 'Authorization' => "Bearer #{token}" }
          end
          it 'status_code: okを返すこと' do
            expect(response).to have_http_status(:ok)
          end
          it 'jsonであること' do
            expect(response.content_type).to eq('application/json; charset=utf-8')
          end
          it 'target_userの情報が更新されていること' do
            contract = Contract.find_by(user_id: target_user.id)
            expect(contract).to be_present
            expect(contract.max_member_count).to eq(10)
          end
        end
      end
    end
    context '異常系' do
      context 'contract権限を持たないユーザーがリクエストした場合' do
        let!(:resource) { Resource.find_by(name: 'user') }
        context '正しいパラメータを受け取った場合' do
          let!(:params) do
            {
              user_id: target_user.id,
              max_member_count: 10
            }
          end
          before do
            travel_to Time.zone.local(2023, 5, 10, 3, 0, 0)
            put "/api/contracts/#{target_user.id}", params: params, headers: { 'Authorization' => "Bearer #{token}" }
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
  end

  describe 'DELETE /api/contracts/:user_id' do
    let!(:user) { create(:user, activated: true) }
    let!(:target_user) { create(:user, activated: true) }
    let!(:contract) { create(:contract, user_id: target_user.id) }
    let!(:payload) do
      {
        sub: user.id,
        type: 'api'
      }
    end
    let!(:auth) { generate_token(payload:) }
    let!(:token) { auth.token }
    let!(:permission) { create(:permission, user_id: user.id, resource_id: resource.id) }
    let!(:params) do
      {
        user_id: target_user.id
      }
    end
    context '正常系' do
      let!(:resource) { Resource.find_by(name: 'contract') }
      context 'contract権限を持つユーザーがリクエストした場合' do
        context '正しいパラメータを受け取った場合' do
          before do
            travel_to Time.zone.local(2023, 5, 10, 3, 0, 0)
            delete "/api/contracts/#{target_user.id}", params: params, headers: { 'Authorization' => "Bearer #{token}" }
          end
          it 'status_code: okを返すこと' do
            expect(response).to have_http_status(:ok)
          end
          it 'jsonであること' do
            expect(response.content_type).to eq('application/json; charset=utf-8')
          end
        end
      end
    end
    context '異常系' do
      context 'contract権限を持たないユーザーがリクエストした場合' do
        let!(:resource) { Resource.find_by(name: 'user') }
        before do
          travel_to Time.zone.local(2023, 5, 10, 3, 0, 0)
          get "/api/contracts/#{target_user.id}", params: params, headers: { 'Authorization' => "Bearer #{token}" }
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
end
