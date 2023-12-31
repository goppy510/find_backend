# frozen_string_literal: true

require 'rails_helper'

describe Api::PermissionsController, type: :request do
  include SessionModule

  describe 'POST /api/permissions' do
    let!(:user) { create(:user, activated: true) }
    let!(:permission) { create(:permission, user_id: user.id, resource_id: permission_resource.id) }
    let!(:payload) do
      {
        sub: user.id,
        type: 'api'
      }
    end
    let!(:auth) { generate_token(payload:) }
    let!(:token) { auth.token }
    let!(:target_user) { create(:user, activated: true) }

    context '正常系' do
      let!(:permission_resource) { Resource.find_by(name: 'permission') }
      context '正しいパラメータを受け取った場合' do
        let!(:permissions) do
          [
            'user',
            'contract'
          ]
        end
        let!(:params) do
          {
            target_user_id: target_user.id,
            permissions: permissions
            
          }
        end
        before do
          post '/api/permissions', params: params,  headers: { 'Authorization' => "Bearer #{token}" }
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
      context 'パラメータがなかった場合' do
        let!(:permission_resource) { Resource.find_by(name: 'permission') }
        before do
          post '/api/permissions', params: {},  headers: { 'Authorization' => "Bearer #{token}" }
        end
        it 'status_code: 400を返すこと' do
          expect(response).to have_http_status(400)
        end
        it 'ActionController::BadRequestを返すこと' do
          expect(JSON.parse(response.body)['error']['code']).to eq('ActionController::BadRequest')
        end
      end

      context '権限がなかった場合' do
        let!(:permission_resource) { Resource.find_by(name: 'contract') }
        let!(:permissions) do
          [
            'user',
            'contract'
          ]
        end
        let!(:params) do
          {
            target_user_id: target_user.id,
            permissions: permissions
            
          }
        end
        let!(:contract_resource) { create(:resource, name: 'contract') }
        before do
          post '/api/permissions', params: params,  headers: { 'Authorization' => "Bearer #{token}" }
        end
        it 'status_code: 403を返すこと' do
          expect(response).to have_http_status(403)
        end
        it 'PermissionService::Forbiddenを返すこと' do
          expect(JSON.parse(response.body)['error']['code']).to eq('Permissions::PermissionError::Forbidden')
        end
      end
    end
  end

  describe 'GET /api/permissions/:user_id' do
    let!(:user) { create(:user, activated: true) }
    let!(:permission) { create(:permission, user_id: user.id, resource_id: permission_resource.id) }
    let!(:payload) do
      {
        sub: user.id,
        type: 'api'
      }
    end
    let!(:auth) { generate_token(payload:) }
    let!(:token) { auth.token }
    let!(:target_user) { create(:user, activated: true) }
    let!(:db_permissions) do
      create(:permission, user_id: target_user.id, resource_id: Resource.find_by(name: 'contract').id)
      create(:permission, user_id: target_user.id, resource_id: Resource.find_by(name: 'user').id)
    end
    before do
      get "/api/permissions/#{target_user.id}", params: params, headers: { 'Authorization' => "Bearer #{token}" }
    end

    context '正常系' do
      context '正しいtarget_user_idを受け取った場合' do
        let!(:permission_resource) { Resource.find_by(name: 'permission') }
        let!(:params) do
          {
            target_user_id: target_user.id
          }
        end
        it 'jsonであること' do
          expect(response.content_type).to eq('application/json; charset=utf-8')
        end
        it 'jsonでpermissionsの中身を受け取ること' do
          expect(JSON.parse(response.body)["permissions"]).to include('contract', 'user')
        end
        it 'status_code: okを返すこと' do
          expect(response).to have_http_status(:ok)
        end
      end
    end

    context '異常系' do
      context 'パラメータがなかった場合' do
        let!(:permission_resource) { Resource.find_by(name: 'permission') }
        let!(:params) { {} }
        it 'status_code: 400を返すこと' do
          expect(response).to have_http_status(400)
        end
        it 'ActionController::BadRequestを返すこと' do
          expect(JSON.parse(response.body)['error']['code']).to eq('ActionController::BadRequest')
        end
      end
      context '権限がなかった場合' do
        let!(:permission_resource) { Resource.find_by(name: 'contract') }
        let!(:params) do
          {
            target_user_id: target_user.id
          }
        end
        it 'status_code: 403を返すこと' do
          expect(response).to have_http_status(403)
        end
        it 'PermissionService::Forbiddenを返すこと' do
          expect(JSON.parse(response.body)['error']['code']).to eq('Permissions::PermissionError::Forbidden')
        end
      end
    end
  end

  describe 'DELETE /api/permissions/:user_id' do
    let!(:user) { create(:user, activated: true) }
    let!(:contract_resource) { Resource.find_by(name: 'contract') }
    let!(:user_resource) { Resource.find_by(name: 'user') }
    let!(:target_user) { create(:user, activated: true) }
    let!(:permission) { create(:permission, user_id: user.id, resource_id: permission_resource.id) }
    let!(:payload) do
      {
        sub: user.id,
        type: 'api'
      }
    end
    let!(:auth) { generate_token(payload:) }
    let!(:token) { auth.token }
    let!(:db_permissions) do
      create(:permission, user_id: target_user.id, resource_id: contract_resource.id)
      create(:permission, user_id: target_user.id, resource_id: user_resource.id)
    end
    before do
      delete "/api/permissions/#{target_user.id}", params: params, headers: { 'Authorization' => "Bearer #{token}" }
    end

    context '正常系' do
      context '正しいパラメータを受け取った場合' do
        let!(:permission_resource) { Resource.find_by(name: 'permission') }
        let!(:permissions) do
          [
            'contract'
          ]
        end
        let!(:params) do
          {
            target_user_id: target_user.id,
            permissions: permissions
          }
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
      context 'パラメータがなかった場合' do
        let!(:permission_resource) { Resource.find_by(name: 'permission') }
        let!(:params) { {} }
        it 'status_code: 400を返すこと' do
          expect(response).to have_http_status(400)
        end
        it 'ActionController::BadRequestを返すこと' do
          expect(JSON.parse(response.body)['error']['code']).to eq('ActionController::BadRequest')
        end
      end
      context '権限がなかった場合' do
        let!(:permission_resource) { Resource.find_by(name: 'contract') }
        let!(:permissions) do
          [
            'contract'
          ]
        end
        let!(:params) do
          {
            target_user_id: target_user.id,
            permissions: permissions
          }
        end
        it 'status_code: 403を返すこと' do
          expect(response).to have_http_status(403)
        end
        it 'PermissionService::Forbiddenを返すこと' do
          expect(JSON.parse(response.body)['error']['code']).to eq('Permissions::PermissionError::Forbidden')
        end
      end
    end
  end
end
