# frozen_string_literal: true

require 'rails_helper'
require 'rspec-rails'
require 'faker'

describe Permissions::PermissionDomain do
  include SessionModule

  before do
    travel_to Time.zone.local(2023, 5, 10, 3, 0, 0)
  end
  describe '#self.create' do
    context '正常系' do
      context '正しい対象のユーザーIDと追加する正しい権限を受け取った場合' do
        let!(:manager_user) { create(:user, activated: true) }
        let!(:target_user) { create(:user, activated: true) }
        let!(:permissions) { 
          [
            'user',
            'create_prompt'
          ]
        }

        it '権限が追加されること' do
          domain = Permissions::PermissionDomain.new(target_user.id, permissions)
          domain.create
          user_resource_id = Resource.find_by(name: 'user').id
          create_prompt_resource_id = Resource.find_by(name: 'create_prompt').id

          expect(Permission.find_by(user_id: target_user.id, resource_id: user_resource_id)).to be_truthy
          expect(Permission.find_by(user_id: target_user.id, resource_id: create_prompt_resource_id)).to be_truthy
        end
      end
    end

    context '異常系' do
      context '対象のユーザーIDが引数にない場合' do
        let!(:manager_user) { create(:user, activated: true) }
        let!(:permissions) { 
          [
            'user',
            'create_prompt'
          ]
        }

        it 'ArgumentErrorがスローされること' do
          expect { Permissions::PermissionDomain.create(nil, permissions) }.to raise_error(ArgumentError, 'target_user_idがありません')
        end
      end

      context '権限が引数にない場合' do
        let!(:manager_user) { create(:user, activated: true) }
        let!(:target_user) { create(:user, activated: true) }

        it 'ArgumentErrorがスローされること' do
          expect { Permissions::PermissionDomain.create(target_user.id, nil) }.to raise_error(ArgumentError, 'permissionsがありません')
        end
      end
    end
  end

  describe '#self.show' do
    context '正常系' do
      context '正しい対象のユーザーIDを受け取った場合' do
        let!(:manager_user) { create(:user, activated: true) }
        let!(:target_user) { create(:user, activated: true) }
        let!(:permissions) { 
          [
            'user',
            'create_prompt'
          ]
        }

        it '権限が表示されること' do
          domain = Permissions::PermissionDomain.new(target_user.id, permissions)
          domain.create
          user_resource_id = Resource.find_by(name: 'user').id
          create_prompt_resource_id = Resource.find_by(name: 'create_prompt').id

          expect(domain.show).to eq(['user', 'create_prompt'])
        end
      end
    end

    context '異常系' do
      context '対象のユーザーIDが引数にない場合' do
        let!(:manager_user) { create(:user, activated: true) }

        it 'ArgumentErrorがスローされること' do
          expect { Permissions::PermissionDomain.show(nil) }.to raise_error(ArgumentError, 'target_user_idがありません')
        end
      end
    end
  end

  describe '#self.delete' do
    context '正常系' do
      context '正しい対象のユーザーIDと削除する正しい権限を受け取った場合' do
        let!(:manager_user) { create(:user, activated: true) }
        let!(:target_user) { create(:user, activated: true) }
        let!(:permissions) { 
          [
            'user',
            'create_prompt'
          ]
        }

        it '権限が削除されること' do
          domain = Permissions::PermissionDomain.new(target_user.id, permissions)
          domain.create
          user_resource_id = Resource.find_by(name: 'user').id
          create_prompt_resource_id = Resource.find_by(name: 'create_prompt').id
          domain.destroy

          expect(Permission.find_by(user_id: target_user.id, resource_id: user_resource_id)).to be_falsey
          expect(Permission.find_by(user_id: target_user.id, resource_id: create_prompt_resource_id)).to be_falsey
        end
      end
    end

    context '異常系' do
      context '対象のユーザーIDが引数にない場合' do
        let!(:manager_user) { create(:user, activated: true) }
        let!(:permissions) { 
          [
            'user',
            'create_prompt'
          ]
        }

        it 'ArgumentErrorがスローされること' do
          expect { Permissions::PermissionDomain.destroy(nil, permissions) }.to raise_error(ArgumentError, 'target_user_idがありません')
        end
      end

      context '権限が引数にない場合' do
        let!(:manager_user) { create(:user, activated: true) }
        let!(:target_user) { create(:user, activated: true) }

        it 'ArgumentErrorがスローされること' do
          expect { Permissions::PermissionDomain.destroy(target_user.id, nil) }.to raise_error(ArgumentError, 'permissionsがありません')
        end
      end
    end
  end
end
