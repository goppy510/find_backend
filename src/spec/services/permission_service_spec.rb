# frozen_string_literal: true

require 'rails_helper'
require 'rspec-rails'
require 'faker'

describe PermissionService do
  include SessionModule

  describe '#self.upsert' do
    context '正常系' do
      context '必要なすべてのパラメータを受け取った場合' do
        before do
          travel_to Time.zone.local(2023, 5, 10, 3, 0, 0)
        end

        let!(:user) { create(:user, activated: true) }
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
              resource: [
                'user',
                'contract'
              ]
            }
          }
        end

        it 'profilesに登録されること' do
          PermissionService.upsert(token, permissions)
          actual = Permission.where(user_id: user.id)
          resource_1 = Resource.find_by(name: permissions[:permissions][:resource][0])
          resource_2 = Resource.find_by(name: permissions[:permissions][:resource][1])
          expect(actual.length).to eq(2)
          expect(actual).to include( have_attributes(resource_id: resource_1.id ) )
          expect(actual).to include( have_attributes(resource_id: resource_2.id ) )
        end
      end

      context 'user_idと存在しないpermissionsを受け取った場合' do
        before do
          travel_to Time.zone.local(2023, 5, 10, 3, 0, 0)
        end
        let!(:user) { create(:user, activated: true) }
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
              resource: [
                'user',
                'contract',
                'hoge'
              ]
            }
          }
        end

        it 'user_idとresource_idでインサートされること' do
          PermissionService.upsert(token, permissions)
          actual = Permission.where(user_id: user.id)
          resource_1 = Resource.find_by(name: permissions[:permissions][:resource][0])
          resource_2 = Resource.find_by(name: permissions[:permissions][:resource][1])
          expect(actual.length).to eq(2)
          expect(actual).to include( have_attributes(resource_id: resource_1.id ) )
          expect(actual).to include( have_attributes(resource_id: resource_2.id ) )
        end
      end

      context 'contractがread_promptに変わった場合' do
        before do
          travel_to Time.zone.local(2023, 5, 10, 3, 0, 0)
        end
        let!(:user) { create(:user, activated: true) }
        let!(:db_permissions) do
          create(:permission, user_id: user.id, resource_id: 1)
          create(:permission, user_id: user.id, resource_id: 2)
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
              resource: [
                'user',
                'read_prompt'
              ]
            }
          }
        end

        it 'userはそのままでcontractがread_promptに変更されること' do
          PermissionService.upsert(token, permissions)
          actual = Permission.where(user_id: user.id)
          resource_1 = Resource.find_by(name: permissions[:permissions][:resource][0])
          resource_2 = Resource.find_by(name: permissions[:permissions][:resource][1])
          expect(actual.length).to eq(2)
          expect(actual).to include( have_attributes(resource_id: resource_1.id ) )
          expect(actual).to include( have_attributes(resource_id: resource_2.id ) )
        end
      end

      context 'contractを削除した場合' do
        before do
          travel_to Time.zone.local(2023, 5, 10, 3, 0, 0)
        end
        let!(:user) { create(:user, activated: true) }
        let!(:db_permissions) do
          create(:permission, user_id: user.id, resource_id: 1)
          create(:permission, user_id: user.id, resource_id: 2)
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
              resource: [
                'user'
              ]
            }
          }
        end

        it 'userはそのままでcontractが削除されること' do
          PermissionService.upsert(token, permissions)
          actual = Permission.where(user_id: user.id)
          resource_1 = Resource.find_by(name: permissions[:permissions][:resource][0])
          expect(actual.length).to eq(1)
          expect(actual).to include( have_attributes(resource_id: resource_1.id ) )
        end
      end
    end
  end

  describe '#show' do
    context '正常系' do
      context 'user_idを受け取った場合' do
        before do
          travel_to Time.zone.local(2023, 5, 10, 3, 0, 0)
        end
        let!(:user) { create(:user, activated: true) }
        let!(:contract_resource) { create(:resource, name: 'contract') }
        let!(:user_resource) { create(:resource, name: 'user') }
        let!(:db_permissions) do
          create(:permission, user_id: user.id, resource_id: contract_resource.id)
          create(:permission, user_id: user.id, resource_id: user_resource.id)
        end
        let!(:payload) do
          {
            sub: user.id,
            type: 'api'
          }
        end
        let!(:auth) { generate_token(payload:) }
        let!(:token) { auth.token }

        it 'user_idに紐づくPermissionオブジェクトが返ること' do
          actual = PermissionService.show(token)
          expect(actual[:resource].length).to eq(2)
          expect(actual[:resource]).to include('user', 'contract')
        end
      end
    end
  end
end
