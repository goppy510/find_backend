# frozen_string_literal: true

require 'rails_helper'
require 'rspec-rails'
require 'faker'

describe PermissionService do
  include SessionModule

  describe '#self.create' do
    context '正常系' do
      context 'permission権限を持っている場合' do
        before do
          travel_to Time.zone.local(2023, 5, 10, 3, 0, 0)
        end
        let!(:user) { create(:user, activated: true) }
        let!(:permission_resource) { Resource.find_by(name: 'permission') }
        let!(:permission) { create(:permission, user_id: user.id, resource_id: permission_resource.id) }
        let!(:payload) do
          {
            sub: user.id,
            type: 'api'
          }
        end
        let!(:auth) { generate_token(payload:) }
        let!(:token) { auth.token }

        context '必要なすべてのパラメータを受け取った場合' do
          let!(:target_user) { create(:user, activated: true) }
          let!(:permissions) do
            {
              permissions: {
                target_user_id: target_user.id,
                resource: 'user'
              }
            }
          end

          it 'permissionに登録されること' do
            PermissionService.create(token, permissions)
            actual = Permission.where(user_id: target_user.id)
            resource = Resource.find_by(name: permissions[:permissions][:resource])
            expect(actual.length).to eq(1)
            expect(actual).to include( have_attributes(resource_id: resource.id ) )
          end
        end

        context 'user_idと存在しないpermissionsを受け取った場合' do
          let!(:target_user) { create(:user, activated: true) }
          let!(:permissions) do
            {
              permissions: {
                target_user_id: target_user.id,
                resource: 'hoge'
              }
            }
          end

          it 'user_idとresource_idでインサートされないこと' do
            PermissionService.create(token, permissions)
            actual = Permission.where(user_id: target_user.id)
            resource = Resource.find_by(name: permissions[:permissions][:resource])
            expect(actual.length).to eq(0)
          end
        end
      end
    end

    context '異常系' do
      let!(:user) { create(:user, activated: true) }
      let!(:permission_resource) { create(:resource, name: 'permission') }
      let!(:payload) do
        {
          sub: user.id,
          type: 'api'
        }
      end
      let!(:auth) { generate_token(payload:) }
      let!(:token) { auth.token }

      context 'tokenがない場合' do
        let!(:permission) { create(:permission, user_id: user.id, resource_id: permission_resource.id) }
        let!(:target_user) { create(:user, activated: true) }
        let!(:permissions) do
          {
            permissions: {
              target_user_id: target_user.id,
              resource: 'user'
            }
          }
        end

        it 'ArgumentErrorが発生すること' do
          expect { PermissionService.create(nil, permissions) }.to raise_error(ArgumentError)
        end
      end

      context 'permissionsがない場合' do
        let!(:permission) { create(:permission, user_id: user.id, resource_id: permission_resource.id) }
        let!(:target_user) { create(:user, activated: true) }

        it 'ArgumentErrorが発生すること' do
          expect { PermissionService.create(token, nil) }.to raise_error(ArgumentError)
        end
      end

      context 'permission権限を持っていない場合' do
        let!(:user) { create(:user, activated: true) }
        let!(:contract_resource) { create(:resource, name: 'contract') }
        let!(:permission) { create(:permission, user_id: user.id, resource_id: contract_resource.id) }
        let!(:payload) do
          {
            sub: user.id,
            type: 'api'
          }
        end
        let!(:auth) { generate_token(payload:) }
        let!(:token) { auth.token }
        let!(:target_user) { create(:user, activated: true) }
        let!(:permissions) do
          {
            permissions: {
              target_user_id: target_user.id,
              resource: 'user'
            }
          }
        end

        it 'Forbiddenが発生すること' do
          expect { PermissionService.create(token, permissions) }.to raise_error(PermissionService::Forbidden)
        end
      end
    end
  end

  describe '#self.show' do
    context '正常系' do
      context 'user_idを受け取った場合' do
        before do
          travel_to Time.zone.local(2023, 5, 10, 3, 0, 0)
        end
        let!(:user) { create(:user, activated: true) }
        let!(:permission_resource) { create(:resource, name: 'permission') }
        let!(:permission) { create(:permission, user_id: user.id, resource_id: permission_resource.id) }
        let!(:contract_resource) { Resource.find_by(name: 'contract') }
        let!(:user_resource) { Resource.find_by(name: 'user') }
        let!(:target_user) { create(:user, activated: true) }
        let!(:db_permissions) do
          create(:permission, user_id: target_user.id, resource_id: contract_resource.id)
          create(:permission, user_id: target_user.id, resource_id: user_resource.id)
        end
        let!(:payload) do
          {
            sub: user.id,
            type: 'api'
          }
        end
        let!(:auth) { generate_token(payload:) }
        let!(:token) { auth.token }
        let!(:permissions) do
          {
            permissions: {
              target_user_id: target_user.id
            }
          }
        end

        it 'user_idに紐づくPermissionオブジェクトが返ること' do
          actual = PermissionService.show(token, permissions)
          expect(actual[:resource].length).to eq(2)
          expect(actual[:resource]).to include('user', 'contract')
        end
      end
    end

    context '異常系' do
      context 'tokenがない場合' do
        let!(:user) { create(:user, activated: true) }
        let!(:permission_resource) { create(:resource, name: 'permission') }
        let!(:permission) { create(:permission, user_id: user.id, resource_id: permission_resource.id) }
        let!(:contract_resource) { Resource.find_by(name: 'contract') }
        let!(:user_resource) { Resource.find_by(name: 'user') }
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

        it 'ArgumentErrorが発生すること' do
          expect { PermissionService.show(nil, permissions) }.to raise_error(ArgumentError)
        end
      end

      context 'permissionsがない場合' do
        let!(:user) { create(:user, activated: true) }
        let!(:permission_resource) { create(:resource, name: 'permission') }
        let!(:permission) { create(:permission, user_id: user.id, resource_id: permission_resource.id) }
        let!(:contract_resource) { Resource.find_by(name: 'contract') }
        let!(:user_resource) { Resource.find_by(name: 'user') }
        let!(:target_user) { create(:user, activated: true) }
        let!(:db_permissions) do
          create(:permission, user_id: target_user.id, resource_id: contract_resource.id)
          create(:permission, user_id: target_user.id, resource_id: user_resource.id)
        end
        let!(:payload) do
          {
            sub: user.id,
            type: 'api'
          }
        end
        let!(:auth) { generate_token(payload:) }
        let!(:token) { auth.token }
        let!(:permissions) do
          {
            permissions: {
              target_user_id: nil
            }
          }
        end

        it 'ArgumentErrorが発生すること' do
          expect { PermissionService.show(token, permissions) }.to raise_error(ArgumentError)
        end
      end

      context 'permission権限を持っていない場合' do
        let!(:user) { create(:user, activated: true) }
        let!(:contract_resource) { Resource.find_by(name: 'contract') }
        let!(:permission) { create(:permission, user_id: user.id, resource_id: contract_resource.id) }
        let!(:payload) do
          {
            sub: user.id,
            type: 'api'
          }
        end
        let!(:auth) { generate_token(payload:) }
        let!(:token) { auth.token }
        let!(:target_user) { create(:user, activated: true) }
        let!(:permissions) do
          {
            permissions: {
              target_user_id: target_user.id
            }
          }
        end
        
        it 'Forbiddenが発生すること' do
          expect { PermissionService.show(token, permissions) }.to raise_error(PermissionService::Forbidden)
        end
      end
    end
  end

  describe '#self.delete' do
    context '正常系' do
      context 'permission権限を持っている場合' do
        before do
          travel_to Time.zone.local(2023, 5, 10, 3, 0, 0)
        end
        let!(:user) { create(:user, activated: true) }
        let!(:permission_resource) { create(:resource, name: 'permission') }
        let!(:permission) { create(:permission, user_id: user.id, resource_id: permission_resource.id) }
        let!(:contract_resource) { Resource.find_by(name: 'contract') }
        let!(:user_resource) { Resource.find_by(name: 'user') }
        let!(:target_user) { create(:user, activated: true) }
        let!(:db_permissions) do
          create(:permission, user_id: target_user.id, resource_id: contract_resource.id)
          create(:permission, user_id: target_user.id, resource_id: user_resource.id)
        end
        let!(:payload) do
          {
            sub: user.id,
            type: 'api'
          }
        end
        let!(:auth) { generate_token(payload:) }
        let!(:token) { auth.token }
        let!(:permissions) do
          {
            permissions: {
              target_user_id: target_user.id,
              resource: 'user'
            }
          }
        end

        it 'user_idに紐づくPermissionオブジェクトが削除されること' do
          PermissionService.delete(token, permissions)
          actual = Permission.where(user_id: target_user.id)
          expect(actual.length).to eq(1)
          expect(actual).to include( have_attributes(resource_id: contract_resource.id ) )
        end
      end
    end

    context '異常系' do
      let!(:contract_resource) { Resource.find_by(name: 'contract') }
      let!(:user_resource) { Resource.find_by(name: 'user') }

      context 'tokenがない場合' do
        let!(:user) { create(:user, activated: true) }
        let!(:permission_resource) { create(:resource, name: 'permission') }
        let!(:permission) { create(:permission, user_id: user.id, resource_id: permission_resource.id) }
        let!(:target_user) { create(:user, activated: true) }
        let!(:db_permissions) do
          create(:permission, user_id: target_user.id, resource_id: contract_resource.id)
          create(:permission, user_id: target_user.id, resource_id: user_resource.id)
        end
        let!(:permissions) do
          {
            permissions: {
              target_user_id: target_user.id,
              resource: 'user'
            }
          }
        end

        it 'ArgumentErrorが発生すること' do
          expect { PermissionService.delete(nil, permissions) }.to raise_error(ArgumentError)
        end
      end
      
      context 'permissionsがない場合' do
        let!(:user) { create(:user, activated: true) }
        let!(:permission_resource) { create(:resource, name: 'permission') }
        let!(:permission) { create(:permission, user_id: user.id, resource_id: permission_resource.id) }
        let!(:target_user) { create(:user, activated: true) }
        let!(:db_permissions) do
          create(:permission, user_id: target_user.id, resource_id: contract_resource.id)
          create(:permission, user_id: target_user.id, resource_id: user_resource.id)
        end
        let!(:payload) do
          {
            sub: user.id,
            type: 'api'
          }
        end
        let!(:auth) { generate_token(payload:) }
        let!(:token) { auth.token }

        it 'ArgumentErrorが発生すること' do
          expect { PermissionService.delete(token, nil) }.to raise_error(ArgumentError)
        end
      end

      context 'permission権限を持っていない場合' do
        let!(:user) { create(:user, activated: true) }
        let!(:permission) { create(:permission, user_id: user.id, resource_id: contract_resource.id) }
        let!(:payload) do
          {
            sub: user.id,
            type: 'api'
          }
        end
        let!(:auth) { generate_token(payload:) }
        let!(:token) { auth.token }
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

        it 'Forbiddenが発生すること' do
          expect { PermissionService.delete(token, permissions) }.to raise_error(PermissionService::Forbidden)
        end
      end
    end
  end

  describe '#self.has_contract_role?' do
    context '正常系' do
      context 'contract権限を持つユーザーの場合' do
        before do
          travel_to Time.zone.local(2023, 5, 10, 3, 0, 0)
        end
        let!(:user) { create(:user, activated: true) }
        let!(:contract_resource) { Resource.find_by(name: 'contract') }
        let!(:permission) { create(:permission, user_id: user.id, resource_id: contract_resource.id) }
        let!(:payload) do
          {
            sub: user.id,
            type: 'api'
          }
        end
        let!(:auth) { generate_token(payload:) }
        let!(:token) { auth.token }

        it 'trueが返ること' do
          actual = PermissionService.has_contract_role?(token)
          expect(actual).to eq(true)
        end
      end

      context 'contract権限を持たないユーザーの場合' do
        before do
          travel_to Time.zone.local(2023, 5, 10, 3, 0, 0)
        end
        let!(:user) { create(:user, activated: true) }
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

        it 'falseが返ること' do
          actual = PermissionService.has_contract_role?(token)
          expect(actual).to eq(false)
        end
      end
    end
  end

  describe '#self.has_permisssion_role?' do
    context '正常系' do
      context 'permission権限を持つユーザーの場合' do
        before do
          travel_to Time.zone.local(2023, 5, 10, 3, 0, 0)
        end
        let!(:user) { create(:user, activated: true) }
        let!(:permission_resource) { Resource.find_by(name: 'permission') }
        let!(:permission) { create(:permission, user_id: user.id, resource_id: permission_resource.id) }
        let!(:payload) do
          {
            sub: user.id,
            type: 'api'
          }
        end
        let!(:auth) { generate_token(payload:) }
        let!(:token) { auth.token }

        it 'trueが返ること' do
          actual = PermissionService.has_permisssion_role?(token)
          expect(actual).to eq(true)
        end
      end

      context 'permission権限を持たないユーザーの場合' do
        before do
          travel_to Time.zone.local(2023, 5, 10, 3, 0, 0)
        end
        let!(:user) { create(:user, activated: true) }
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

        it 'falseが返ること' do
          actual = PermissionService.has_permisssion_role?(token)
          expect(actual).to eq(false)
        end
      end
    end
  end

  describe '#self.has_user_role?' do
    context '正常系' do
      context 'user権限を持つユーザーの場合' do
        before do
          travel_to Time.zone.local(2023, 5, 10, 3, 0, 0)
        end
        let!(:user) { create(:user, activated: true) }
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

        it 'trueが返ること' do
          actual = PermissionService.has_user_role?(token)
          expect(actual).to eq(true)
        end
      end

      context 'user権限を持たないユーザーの場合' do
        before do
          travel_to Time.zone.local(2023, 5, 10, 3, 0, 0)
        end
        let!(:user) { create(:user, activated: true) }
        let!(:contract_resource) { Resource.find_by(name: 'contract') }
        let!(:permission) { create(:permission, user_id: user.id, resource_id: contract_resource.id) }
        let!(:payload) do
          {
            sub: user.id,
            type: 'api'
          }
        end
        let!(:auth) { generate_token(payload:) }
        let!(:token) { auth.token }

        it 'falseが返ること' do
          actual = PermissionService.has_user_role?(token)
          expect(actual).to eq(false)
        end
      end
    end
  end
end
