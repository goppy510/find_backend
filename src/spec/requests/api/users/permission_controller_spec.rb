# frozen_string_literal: true

require 'rails_helper'

describe Api::Users::PermissionController, type: :request do
  include SessionModule

  describe 'POST /api/users/permission' do
    context '正常系' do
      let!(:user) { create(:user, activated: true) }
      let!(:permission_resource) { create(:resource, name: 'permission') }
      let!(:permission) { create(:permission, user_id: user.id, resource_id: permission_resource.id) }
      let!(:payload) do
        {
          sub: user.id,
          type: 'api'
        }
      end
      let!(:auth) { generate_token(payload:) }
      let!(:token) { auth.token }

      context '正しいパラメータを受け取った場合' do
        let!(:target_user) { create(:user, activated: true) }
        let!(:permissions) do
          {
            permissions: {
              target_user_id: target_user.id,
              resource: [
                'user',
                'contract'
              ]
            }
          }
        end

        before do
          post '/api/users/permission', params: permissions,  headers: { 'Authorization' => "Bearer #{token}" }
        end

        it 'status_code: okを返すこと' do
          expect(response).to have_http_status(:ok)
        end

        it 'statusがsuccessであること' do
          expect(JSON.parse(response.body)['status']).to eq('success')
        end
      end
    end

    context '異常系' do
      let!(:user) { create(:user, activated: true) }
      let!(:payload) do
        {
          sub: user.id,
          type: 'api'
        }
      end
      let!(:auth) { generate_token(payload:) }
      let!(:token) { auth.token }

      context 'パラメータがなかった場合' do
        let!(:permission_resource) { create(:resource, name: 'permission') }
        let!(:permission) { create(:permission, user_id: user.id, resource_id: permission_resource.id) }
        before do
          post '/api/users/permission', params: {},  headers: { 'Authorization' => "Bearer #{token}" }
        end
        it 'status_code: 400を返すこと' do
          expect(response).to have_http_status(400)
        end
        it 'ActionController::BadRequestを返すこと' do
          expect(JSON.parse(response.body)['error']['code']).to eq('ActionController::BadRequest')
        end
      end

      context '権限がなかった場合' do
        let!(:contract_resource) { create(:resource, name: 'contract') }
        let!(:permission) { create(:permission, user_id: user.id, resource_id: contract_resource.id) }
        let!(:target_user) { create(:user, activated: true) }
        let!(:permissions) do
          {
            permissions: {
              target_user_id: target_user.id,
              resource: [
                'user',
                'contract'
              ]
            }
          }
        end
        before do
          post '/api/users/permission', params: permissions,  headers: { 'Authorization' => "Bearer #{token}" }
        end
        it 'status_code: 403を返すこと' do
          expect(response).to have_http_status(403)
        end
        it 'PermissionService::Forbiddenを返すこと' do
          expect(JSON.parse(response.body)['error']['code']).to eq('PermissionService::Forbidden')
        end
      end
    end
  end

  describe 'GET /api/users/permission' do
    context '正常系' do
      let!(:user) { create(:user, activated: true) }
      let!(:permission_resource) { create(:resource, name: 'permission') }
      let!(:permission) { create(:permission, user_id: user.id, resource_id: permission_resource.id) }
      let!(:payload) do
        {
          sub: user.id,
          type: 'api'
        }
      end
      let!(:auth) { generate_token(payload:) }
      let!(:token) { auth.token }

      context '正しいtarget_user_idを受け取った場合' do
        let!(:contract_resource) { create(:resource, name: 'contract') }
        let!(:user_resource) { create(:resource, name: 'user') }
        let!(:target_user) { create(:user, activated: true) }
        let!(:db_permissions) do
          create(:permission, user_id: target_user.id, resource_id: contract_resource.id)
          create(:permission, user_id: target_user.id, resource_id: user_resource.id)
        end
        let!(:permissions) do
          {
            permissions: {
              target_user_id: target_user.id
            }
          }
        end
        before do
          get '/api/users/permission', params: permissions, headers: { 'Authorization' => "Bearer #{token}" }
        end

        it 'jsonであること' do
          expect(response.content_type).to eq('application/json; charset=utf-8')
        end
        it 'jsonでprofilesの中身を受け取ること' do
          expect(JSON.parse(response.body)["resource"]).to include('contract', 'user')
        end
        it 'status_code: okを返すこと' do
          expect(response).to have_http_status(:ok)
        end
      end
    end

    context '異常系' do
      let!(:user) { create(:user, activated: true) }
      let!(:permission_resource) { create(:resource, name: 'permission') }
      let!(:permission) { create(:permission, user_id: user.id, resource_id: permission_resource.id) }
      let!(:payload) do
        {
          sub: user.id,
          type: 'api'
        }
      end
      let!(:auth) { generate_token(payload:) }
      let!(:token) { auth.token }

      context 'パラメータがなかった場合' do
        before do
          get '/api/users/permission', params: {}, headers: { 'Authorization' => "Bearer #{token}" }
        end
        it 'status_code: 400を返すこと' do
          expect(response).to have_http_status(400)
        end
        it 'ActionController::BadRequestを返すこと' do
          expect(JSON.parse(response.body)['error']['code']).to eq('ActionController::BadRequest')
        end
      end

      context '権限がなかった場合' do
        let!(:contract_resource) { create(:resource, name: 'contract') }
        let!(:permission) { create(:permission, user_id: user.id, resource_id: contract_resource.id) }
        let!(:target_user) { create(:user, activated: true) }
        let!(:permissions) do
          {
            permissions: {
              target_user_id: target_user.id
            }
          }
        end
        before do
          get '/api/users/permission', params: permissions, headers: { 'Authorization' => "Bearer #{token}" }
        end
        it 'status_code: 403を返すこと' do
          expect(response).to have_http_status(403)
        end
        it 'PermissionService::Forbiddenを返すこと' do
          expect(JSON.parse(response.body)['error']['code']).to eq('PermissionService::Forbidden')
        end
      end
    end
  end
end
