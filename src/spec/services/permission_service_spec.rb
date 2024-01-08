spec/services/permission_service_spec.rb
# frozen_string_literal: true

require 'rails_helper'
require 'rspec-rails'
require 'faker'

describe PermissionService do
  include SessionModule

  describe '#self.create' do
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
    let!(:contract) { create(:contract, user_id: user.id) }

    context '正常系' do
      let!(:contract_membership) { create(:contract_membership, user_id: target_user.id, contract_id: contract.id) }
      context 'permission権限を持っている場合' do
        before do
          travel_to Time.zone.local(2023, 5, 10, 3, 0, 0)
        end
        let!(:permission_resource) { Resource.find_by(name: 'permission') }
        context '必要なすべてのパラメータを受け取った場合' do
          let!(:permissions) do
            [
              'user',
              'contract'
            ]
          end

          it 'permissionに登録されること' do
            PermissionService.create(token, target_user.id, permissions)
            actual = Permission.where(user_id: target_user.id)
            user_resource = Resource.find_by(name: permissions[0])
            contract_resource = Resource.find_by(name: permissions[1])
            expect(actual.length).to eq(2)
            expect(actual).to include( have_attributes(resource_id: user_resource.id ) )
            expect(actual).to include( have_attributes(resource_id: contract_resource.id ) )
          end
        end

        context 'user_idと存在しないpermissionsを受け取った場合' do
          let!(:permissions) do
            [
              'user',
              'contract',
              'test'
            ]
          end

          it '存在する権限のみpermissionに登録されること' do
            PermissionService.create(token, target_user.id, permissions)
            actual = Permission.where(user_id: target_user.id)
            user_resource = Resource.find_by(name: permissions[0])
            contract_resource = Resource.find_by(name: permissions[1])
            expect(actual.length).to eq(2)
            expect(actual).to include( have_attributes(resource_id: user_resource.id ) )
            expect(actual).to include( have_attributes(resource_id: contract_resource.id ) )
          end
        end
      end
    end

    context '異常系' do
      let!(:permission_resource) { create(:resource, name: 'permission') }
      let!(:permission) { create(:permission, user_id: user.id, resource_id: permission_resource.id) }

      context 'tokenがない場合' do
        let!(:permissions) do
          [
            'user',
            'contract'
          ]
        end
        it 'ArgumentErrorが発生すること' do
          expect { PermissionService.create(nil, target_user.id, permissions) }.to raise_error(ArgumentError)
        end
      end
      context 'permissionsがない場合' do
        let!(:permission) { create(:permission, user_id: user.id, resource_id: permission_resource.id) }
        it 'ArgumentErrorが発生すること' do
          expect { PermissionService.create(token, target_user.id, nil) }.to raise_error(ArgumentError)
        end
      end
      context 'target_user_idがない場合' do
        let!(:contract_membership) { create(:contract_membership, user_id: target_user.id, contract_id: contract.id) }
        let!(:permission) { create(:permission, user_id: user.id, resource_id: permission_resource.id) }
        let!(:permissions) do
          [
            'user',
            'contract'
          ]
        end
        it 'ArgumentErrorが発生すること' do
          expect { PermissionService.create(token, nil, permissions) }.to raise_error(ArgumentError)
        end
      end
      context 'permission権限を持っていない場合' do
        let!(:contract_membership) { create(:contract_membership, user_id: target_user.id, contract_id: contract.id) }
        let!(:contract_resource) { create(:resource, name: 'contract') }
        let!(:permission) { create(:permission, user_id: user.id, resource_id: contract_resource.id) }
        let!(:permissions) do
          [
            'user',
            'contract'
          ]
        end
        it 'Forbiddenが発生すること' do
          expect { PermissionService.create(token, target_user.id, permissions) }.to raise_error(Permissions::PermissionError::Forbidden)
        end
      end
      context 'target_user_idが権限者と異なるcontractsの場合' do
        let!(:contract_resource) { create(:resource, name: 'contract') }
        let!(:permission) { create(:permission, user_id: user.id, resource_id: permission_resource.id) }
        let!(:permissions) do
          [
            'user',
            'contract'
          ]
        end
        it 'Forbiddenが発生すること' do
          expect { PermissionService.create(token, target_user.id, permissions) }.to raise_error(Permissions::PermissionError::Forbidden)
        end
      end
    end
  end

  describe '#self.show' do
    let!(:user) { create(:user, activated: true) }
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
      [
        'user',
        'contract'
      ]
    end
    let!(:contract) { create(:contract, user_id: user.id) }

    context '正常系' do
      let!(:contract_membership) { create(:contract_membership, user_id: target_user.id, contract_id: contract.id) }
      before do
        travel_to Time.zone.local(2023, 5, 10, 3, 0, 0)
      end
      context 'user_idを受け取った場合' do
        let!(:permission_resource) { create(:resource, name: 'permission') }
        it 'user_idに紐づくPermissionオブジェクトが返ること' do
          actual = PermissionService.show(token, target_user.id)
          expect(actual[:permissions].length).to eq(2)
          expect(actual[:permissions]).to include('user', 'contract')
        end
      end
      context '権限はないが対象ユーザーが自分自身の場合' do
        let!(:permission_resource) { create(:resource, name: 'contract') }
        it 'user_idに紐づくPermissionオブジェクトが返ること' do
          actual = PermissionService.show(token, user.id)
          expect(actual[:permissions].length).to eq(1)
          expect(actual[:permissions]).to include('contract')
        end
      end
    end

    context '異常系' do
      context 'tokenがない場合' do
        let!(:contract_membership) { create(:contract_membership, user_id: target_user.id, contract_id: contract.id) }
        let!(:permission_resource) { create(:resource, name: 'permission') }
        let!(:db_permissions) do
          create(:permission, user_id: target_user.id, resource_id: contract_resource.id)
          create(:permission, user_id: target_user.id, resource_id: user_resource.id)
        end
        it 'ArgumentErrorが発生すること' do
          expect { PermissionService.show(nil, target_user.id) }.to raise_error(ArgumentError)
        end
      end

      context 'target_user_idがない場合' do
        let!(:contract_membership) { create(:contract_membership, user_id: target_user.id, contract_id: contract.id) }
        let!(:permission_resource) { create(:resource, name: 'permission') }
        let!(:db_permissions) do
          create(:permission, user_id: target_user.id, resource_id: contract_resource.id)
          create(:permission, user_id: target_user.id, resource_id: user_resource.id)
        end
        it 'ArgumentErrorが発生すること' do
          expect { PermissionService.show(token, nil) }.to raise_error(ArgumentError)
        end
      end

      context 'permission権限を持っていない場合' do
        let!(:contract_membership) { create(:contract_membership, user_id: target_user.id, contract_id: contract.id) }
        let!(:permission_resource) { create(:resource, name: 'contract') }        
        it 'Forbiddenが発生すること' do
          expect { PermissionService.show(token, target_user.id) }.to raise_error(Permissions::PermissionError::Forbidden)
        end
      end

      context 'target_user_idが権限者と異なるcontractsの場合' do
        let!(:permission_resource) { create(:resource, name: 'permission') }
        it 'Forbiddenが発生すること' do
          expect { PermissionService.show(token, target_user.id) }.to raise_error(Permissions::PermissionError::Forbidden)
        end
      end
    end
  end

  describe '#self.destroy' do
    let!(:user) { create(:user, activated: true) }
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
      [
        'user'
      ]
    end
    let!(:contract) { create(:contract, user_id: user.id) }

    context '正常系' do
      let!(:contract_membership) { create(:contract_membership, user_id: target_user.id, contract_id: contract.id) }
      context 'permission権限を持っている場合' do
        let!(:permission_resource) { create(:resource, name: 'permission') }
        before do
          travel_to Time.zone.local(2023, 5, 10, 3, 0, 0)
        end
        it 'user_idに紐づくPermissionオブジェクトが削除されること' do
          PermissionService.destroy(token, target_user.id, permissions)
          actual = Permission.where(user_id: target_user.id)
          expect(actual.length).to eq(1)
          expect(actual).to include( have_attributes(resource_id: contract_resource.id ) )
        end
      end
    end

    context '異常系' do
      context 'tokenがない場合' do
        let!(:contract_membership) { create(:contract_membership, user_id: target_user.id, contract_id: contract.id) }
        let!(:permission_resource) { create(:resource, name: 'permission') }
        it 'ArgumentErrorが発生すること' do
          expect { PermissionService.destroy(nil, target_user.id, permissions) }.to raise_error(ArgumentError)
        end
      end
      context 'permissionsがない場合' do
        let!(:contract_membership) { create(:contract_membership, user_id: target_user.id, contract_id: contract.id) }
        let!(:permission_resource) { create(:resource, name: 'permission') }
        it 'ArgumentErrorが発生すること' do
          expect { PermissionService.destroy(token, target_user.id, nil) }.to raise_error(ArgumentError)
        end
      end
      context 'target_user_idがない場合' do
        let!(:contract_membership) { create(:contract_membership, user_id: target_user.id, contract_id: contract.id) }
        let!(:permission_resource) { create(:resource, name: 'permission') }
        it 'ArgumentErrorが発生すること' do
          expect { PermissionService.destroy(token, nil, permissions) }.to raise_error(ArgumentError)
        end
      end
      context 'permission権限を持っていない場合' do
        let!(:contract_membership) { create(:contract_membership, user_id: target_user.id, contract_id: contract.id) }
        let!(:permission_resource) { create(:resource, name: 'contract') }
        it 'Forbiddenが発生すること' do
          expect { PermissionService.destroy(token, target_user.id, permissions) }.to raise_error(Permissions::PermissionError::Forbidden)
        end
      end
      context 'target_user_idが権限者と異なるcontractsの場合' do
        let!(:permission_resource) { create(:resource, name: 'permission') }
        it 'Forbiddenが発生すること' do
          expect { PermissionService.destroy(token, target_user.id, permissions) }.to raise_error(Permissions::PermissionError::Forbidden)
        end
      end
    end
  end

  describe '#self.has_admin_role?' do
    let!(:user) { create(:user, activated: true) }
    let!(:permission) { create(:permission, user_id: user.id, resource_id: permission_resource.id) }

    context '正常系' do
      context 'admin権限を持つユーザーの場合' do
        let!(:permission_resource) { Resource.find_by(name: 'admin') }
        it 'trueが返ること' do
          actual = PermissionService.has_admin_role?(user.id)
          expect(actual).to eq(true)
        end
      end

      context 'admin権限を持たないユーザーの場合' do
        let!(:permission_resource) { Resource.find_by(name: 'user') }
        it 'falseが返ること' do
          actual = PermissionService.has_admin_role?(user.id)
          expect(actual).to eq(false)
        end
      end
    end
  end

  describe '#self.has_contract_role?' do
    let!(:user) { create(:user, activated: true) }
    let!(:permission) { create(:permission, user_id: user.id, resource_id: permission_resource.id) }
    context '正常系' do
      context 'contract権限を持つユーザーの場合' do
        before do
          travel_to Time.zone.local(2023, 5, 10, 3, 0, 0)
        end
        let!(:permission_resource) { Resource.find_by(name: 'contract') }
        it 'trueが返ること' do
          actual = PermissionService.has_contract_role?(user.id)
          expect(actual).to eq(true)
        end
      end

      context 'contract権限を持たないユーザーの場合' do
        before do
          travel_to Time.zone.local(2023, 5, 10, 3, 0, 0)
        end
        let!(:permission_resource) { Resource.find_by(name: 'user') }
        it 'falseが返ること' do
          actual = PermissionService.has_contract_role?(user.id)
          expect(actual).to eq(false)
        end
      end
    end
  end

  describe '#self.has_permisssion_role?' do
    let!(:user) { create(:user, activated: true) }
    let!(:permission) { create(:permission, user_id: user.id, resource_id: permission_resource.id) }
    context '正常系' do
      context 'permission権限を持つユーザーの場合' do
        before do
          travel_to Time.zone.local(2023, 5, 10, 3, 0, 0)
        end
        let!(:permission_resource) { Resource.find_by(name: 'permission') }
        it 'trueが返ること' do
          actual = PermissionService.has_permisssion_role?(user.id)
          expect(actual).to eq(true)
        end
      end

      context 'permission権限を持たないユーザーの場合' do
        before do
          travel_to Time.zone.local(2023, 5, 10, 3, 0, 0)
        end
        let!(:permission_resource) { Resource.find_by(name: 'user') }
        it 'falseが返ること' do
          actual = PermissionService.has_permisssion_role?(user.id)
          expect(actual).to eq(false)
        end
      end
    end
  end

  describe '#self.has_user_role?' do
    let!(:user) { create(:user, activated: true) }
    let!(:permission) { create(:permission, user_id: user.id, resource_id: permission_resource.id) }
    context '正常系' do
      context 'user権限を持つユーザーの場合' do
        before do
          travel_to Time.zone.local(2023, 5, 10, 3, 0, 0)
        end
        let!(:permission_resource) { Resource.find_by(name: 'user') }
        it 'trueが返ること' do
          actual = PermissionService.has_user_role?(user.id)
          expect(actual).to eq(true)
        end
      end

      context 'user権限を持たないユーザーの場合' do
        before do
          travel_to Time.zone.local(2023, 5, 10, 3, 0, 0)
        end
        let!(:permission_resource) { Resource.find_by(name: 'contract') }
        it 'falseが返ること' do
          actual = PermissionService.has_user_role?(user.id)
          expect(actual).to eq(false)
        end
      end
    end
  end

  describe '#self.has_create_prompt_role?' do
    let!(:user) { create(:user, activated: true) }
    let!(:permission) { create(:permission, user_id: user.id, resource_id: permission_resource.id) }
    context '正常系' do
      context 'create_prompt権限を持つユーザーの場合' do
        let!(:permission_resource) { Resource.find_by(name: 'create_prompt') }
        it 'trueが返ること' do
          actual = PermissionService.has_create_prompt_role?(user.id)
          expect(actual).to eq(true)
        end
      end

      context 'create_prompt権限を持たないユーザーの場合' do
        let!(:permission_resource) { Resource.find_by(name: 'user') }
        it 'falseが返ること' do
          actual = PermissionService.has_create_prompt_role?(user.id)
          expect(actual).to eq(false)
        end
      end
    end
  end

  describe '#self.has_read_prompt_role?' do
    let!(:user) { create(:user, activated: true) }
    let!(:permission) { create(:permission, user_id: user.id, resource_id: permission_resource.id) }
    context '正常系' do
      context 'read_prompt権限を持つユーザーの場合' do
        let!(:permission_resource) { Resource.find_by(name: 'read_prompt') }
        it 'trueが返ること' do
          actual = PermissionService.has_read_prompt_role?(user.id)
          expect(actual).to eq(true)
        end
      end

      context 'read_prompt権限を持たないユーザーの場合' do
        let!(:permission_resource) { Resource.find_by(name: 'user') }
        it 'falseが返ること' do
          actual = PermissionService.has_read_prompt_role?(user.id)
          expect(actual).to eq(false)
        end
      end
    end
  end

  describe '#self.has_update_prompt_role?' do
    let!(:user) { create(:user, activated: true) }
    let!(:permission) { create(:permission, user_id: user.id, resource_id: permission_resource.id) }
    context '正常系' do
      context 'update_prompt権限を持つユーザーの場合' do
        let!(:permission_resource) { Resource.find_by(name: 'update_prompt') }
        it 'trueが返ること' do
          actual = PermissionService.has_update_prompt_role?(user.id)
          expect(actual).to eq(true)
        end
      end

      context 'update_prompt権限を持たないユーザーの場合' do
        let!(:permission_resource) { Resource.find_by(name: 'user') }
        it 'falseが返ること' do
          actual = PermissionService.has_update_prompt_role?(user.id)
          expect(actual).to eq(false)
        end
      end
    end
  end

  describe '#self.has_destroy_prompt_role?' do
    let!(:user) { create(:user, activated: true) }
    let!(:permission) { create(:permission, user_id: user.id, resource_id: permission_resource.id) }

    context '正常系' do
      context 'destroy_prompt権限を持つユーザーの場合' do
        let!(:permission_resource) { Resource.find_by(name: 'destroy_prompt') }
        it 'trueが返ること' do
          actual = PermissionService.has_destroy_prompt_role?(user.id)
          expect(actual).to eq(true)
        end
      end

      context 'destroy_prompt権限を持たないユーザーの場合' do
        let!(:permission_resource) { Resource.find_by(name: 'user') }
        it 'falseが返ること' do
          actual = PermissionService.has_destroy_prompt_role?(user.id)
          expect(actual).to eq(false)
        end
      end
    end
  end
end
