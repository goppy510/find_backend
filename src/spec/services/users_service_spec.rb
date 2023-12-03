# frozen_string_literal: true

require 'rails_helper'
require 'rspec-rails'
require 'faker'

describe UsersService do
  include SessionModule

  describe '#self.show' do
    before do
      travel_to Time.zone.local(2023, 5, 10, 3, 0, 0)
      allow(Contracts::UsersDomain).to receive(:show)
    end
    context '正常系' do
      context '正しいパラメータを受け取った場合' do
        let!(:user) { create(:user, activated: true) }
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
        let!(:contract) { create(:contract, user_id: user.id) }
        let!(:contract_membership) { create(:contract_membership, user_id: user.id, contract_id: contract.id) }

        it 'Contracts::UsersDomain.showが呼ばれること' do
          UsersService.show(token, target_user.id)
          expect(Contracts::UsersDomain).to have_received(:show).with(user.id, target_user.id)
        end
      end
    end

    context '異常系' do
      context 'tokenがなかった場合' do
        let!(:target_user) { create(:user, activated: true) }

        it 'ArgumentErrorが発生すること' do
          expect { UsersService.show(nil, target_user.id) }.to raise_error(ArgumentError)
        end
      end

      context 'target_user_idがなかった場合' do
        let!(:user) { create(:user, activated: true) }
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

        it 'ArgumentErrorが発生すること' do
          expect { UsersService.show(token, nil) }.to raise_error(ArgumentError)
        end
      end

      context 'tokenが不正だった場合' do
        let!(:user) { create(:user, activated: true) }
        let!(:payload) do
          {
            sub: user.id,
            type: 'api'
          }
        end
        let!(:auth) { generate_token(payload:) }
        let!(:token) { auth.token }
        let!(:create_prompt_resource) { Resource.find_by(name: 'create_prompt') }
        let!(:permission) { create(:permission, user_id: user.id, resource_id: create_prompt_resource.id) }
        let!(:target_user) { create(:user, activated: true) }

        it 'Forbiddenが発生すること' do
          expect { UsersService.show(token, target_user.id) }.to raise_error(UsersService::Forbidden)
        end
      end
    end
  end

  describe '#self.index' do
    before do
      travel_to Time.zone.local(2023, 5, 10, 3, 0, 0)
      allow(Contracts::UsersDomain).to receive(:index)
    end
    context '正常系' do
      context '正しいパラメータを受け取った場合' do
        let!(:user) { create(:user, activated: true) }
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
        let!(:contract) { create(:contract, user_id: user.id) }
        let!(:contract_membership) { create(:contract_membership, user_id: user.id, contract_id: contract.id) }

        it 'Contracts::UsersDomain.indexが呼ばれること' do
          UsersService.index(token)
          expect(Contracts::UsersDomain).to have_received(:index).with(user.id)
        end
      end
    end

    context '異常系' do
      context 'tokenがなかった場合' do
        it 'ArgumentErrorが発生すること' do
          expect { UsersService.index(nil) }.to raise_error(ArgumentError)
        end
      end

      context 'tokenが不正だった場合' do
        let!(:user) { create(:user, activated: true) }
        let!(:payload) do
          {
            sub: user.id,
            type: 'api'
          }
        end
        let!(:auth) { generate_token(payload:) }
        let!(:token) { auth.token }
        let!(:create_prompt_resource) { Resource.find_by(name: 'create_prompt') }
        let!(:permission) { create(:permission, user_id: user.id, resource_id: create_prompt_resource.id) }

        it 'Forbiddenが発生すること' do
          expect { UsersService.index(token) }.to raise_error(UsersService::Forbidden)
        end
      end
    end
  end

  describe '#self.destroy' do
    before do
      travel_to Time.zone.local(2023, 5, 10, 3, 0, 0)
      allow(Contracts::UsersDomain).to receive(:destroy)
    end
    context '正常系' do
      context '正しいパラメータを受け取った場合' do
        let!(:user) { create(:user, activated: true) }
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
        let!(:contract) { create(:contract, user_id: user.id) }
        let!(:contract_membership) do
          create(:contract_membership, user_id: target_user.id, contract_id: contract.id)
        end

        it 'Contracts::UsersDomain.destroyが呼ばれること' do
          UsersService.destroy(token, target_user.id)
          expect(Contracts::UsersDomain).to have_received(:destroy).with(user.id, target_user.id)
        end
      end
    end

    context '異常系' do
      context 'tokenがなかった場合' do
        let!(:target_user) { create(:user, activated: true) }

        it 'ArgumentErrorが発生すること' do
          expect { UsersService.destroy(nil, target_user.id) }.to raise_error(ArgumentError)
        end
      end

      context 'target_user_idがなかった場合' do
        let!(:user) { create(:user, activated: true) }
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

        it 'ArgumentErrorが発生すること' do
          expect { UsersService.destroy(token, nil) }.to raise_error(ArgumentError)
        end
      end

      context 'tokenが不正だった場合' do
        let!(:user) { create(:user, activated: true) }
        let!(:payload) do
          {
            sub: user.id,
            type: 'api'
          }
        end
        let!(:auth) { generate_token(payload:) }
        let!(:token) { auth.token }
        let!(:create_prompt_resource) { Resource.find_by(name: 'create_prompt') }
        let!(:permission) { create(:permission, user_id: user.id, resource_id: create_prompt_resource.id) }
        let!(:target_user) { create(:user, activated: true) }
        let!(:contract) { create(:contract, user_id: user.id) }
        let!(:contract_membership) do
          create(:contract_membership, user_id: target_user.id, contract_id: contract.id)
        end

        it 'Forbiddenが発生すること' do
          expect { UsersService.destroy(token, target_user.id) }.to raise_error(UsersService::Forbidden)
        end
      end
    end
  end
end
