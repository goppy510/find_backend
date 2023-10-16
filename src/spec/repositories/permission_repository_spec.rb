# frozen_string_literal: true

require 'rails_helper'
require 'rspec-rails'
require 'faker'

describe PermissionRepository do
  before do
    travel_to Time.zone.local(2023, 5, 10, 3, 0, 0)
  end
  let!(:user) { create(:user, activated: true) }

  describe '#self.create' do
    context '正常系' do
      context 'user_idと存在するpermissionsを受け取った場合' do
        let!(:permissions) do
          {
            resource: 'user'
          }
        end

        it 'user_idとresource_idでインサートされること' do
          PermissionRepository.create(user.id, permissions)
          actual = Permission.where(user_id: user.id)
          resource = Resource.find_by(name: permissions[:resource])
          expect(actual.length).to eq(1)
          expect(actual).to include( have_attributes(resource_id: resource.id ) )
        end
      end

      context 'user_idと存在しないpermissionsを受け取った場合' do
        let!(:permissions) do
          {
            resource: 'hoge'
          }
        end

        it 'user_idとresource_idでインサートされないこと' do
          PermissionRepository.create(user.id, permissions)
          actual = Permission.where(user_id: user.id)
          resource = Resource.find_by(name: permissions[:resource])
          expect(actual.length).to eq(0)
        end
      end
    end
  end

  describe '#show' do
    context '正常系' do
      context 'user_idを受け取った場合' do
        let!(:user_resource) { Resource.find_by(name: 'user') }
        let!(:contract_resource) { Resource.find_by(name: 'contract') }
        let!(:db_permissions) do
          create(:permission, user_id: user.id, resource_id: user_resource.id)
          create(:permission, user_id: user.id, resource_id: contract_resource.id)
        end

        it 'user_idに紐づくPermissionオブジェクトが返ること' do
          actual = PermissionRepository.show(user.id)
          expect(actual.length).to eq(2)
          expect(actual).to include('user', 'contract')
        end
      end
    end
  end

  describe '#self.delete' do
    context 'contractを削除した場合' do
      let!(:user_resource) { Resource.find_by(name: 'user') }
      let!(:contract_resource) { Resource.find_by(name: 'contract') }
      let!(:db_permissions) do
        create(:permission, user_id: user.id, resource_id: user_resource.id)
        create(:permission, user_id: user.id, resource_id: contract_resource.id)
      end
      let!(:permissions) do
        {
          resource: [
            'user'
          ]
        }
      end

      it 'userはそのままでcontractが削除されること' do
        PermissionRepository.delete(user.id, permissions)
        actual = Permission.where(user_id: user.id)
        resource = Resource.find_by(name: permissions[:resource])
        expect(actual.length).to eq(1)
        expect(actual).to include( have_attributes(resource_id: contract_resource.id ) )
      end
    end
  end
end
