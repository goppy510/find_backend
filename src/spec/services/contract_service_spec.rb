# frozen_string_literal: true

require 'rails_helper'
require 'rspec-rails'
require 'faker'

describe ContractService do
  include SessionModule

  describe '#self.create' do
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
    let!(:target_user) { create(:user, activated: true) }
    before do
      travel_to Time.zone.local(2023, 5, 10, 3, 0, 0)
      allow(Contracts::ContractDomain).to receive(:create)
    end
    context '正常系' do
      context '正しいtarget_user_idとmax_member_countを受け取った場合' do
        let!(:resource) { Resource.find_by(name: 'contract') }
        let!(:max_member_count) { 10 }
        it 'Contracts::ContractDomain.createが呼ばれること' do
          ContractService.create(token, target_user.id, max_member_count)
          expect(Contracts::ContractDomain).to have_received(:create).with(target_user.id, max_member_count)
        end
      end
      context 'admin権限を持っている場合' do
        let!(:resource) { Resource.find_by(name: 'admin') }
        let!(:max_member_count) { 10 }
        it 'Contracts::ContractDomain.createが呼ばれること' do
          ContractService.create(token, target_user.id, max_member_count)
          expect(Contracts::ContractDomain).to have_received(:create).with(target_user.id, max_member_count)
        end
      end
    end
    context '異常系' do
      context 'tokenが引数にない場合' do
        let!(:resource) { Resource.find_by(name: 'contract') }
        let!(:max_member_count) { 10 }
        it 'ArgumentErrorがスローされること' do
          expect { ContractService.create(nil, target_user.id, max_member_count) }.to raise_error(ArgumentError, 'tokenがありません')
        end
      end
      context 'target_user_idが引数にない場合' do
        let!(:resource) { Resource.find_by(name: 'contract') }
        let!(:max_member_count) { 10 }
        it 'ArgumentErrorがスローされること' do
          expect { ContractService.create(token, nil, max_member_count) }.to raise_error(ArgumentError, 'target_user_idがありません')
        end
      end
      context 'max_member_countが引数にない場合' do
        let!(:resource) { Resource.find_by(name: 'contract') }
        it 'ArgumentErrorがスローされること' do
          expect { ContractService.create(token, target_user.id, nil) }.to raise_error(ArgumentError, 'max_member_countがありません')
        end
      end
      context '権限がなかった場合' do
        let!(:resource) { Resource.find_by(name: 'user') }
        let!(:max_member_count) { 10 }
        it 'Forbiddenがスローされること' do
          expect { ContractService.create(token, target_user.id, max_member_count) }.to raise_error(Contracts::ContractsError::Forbidden)
        end
      end
    end
  end

  describe '#self.show' do
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
    let!(:target_user) { create(:user, activated: true) }
    let!(:contract) { create(:contract, user_id: user.id) }
    let!(:contract_membership) { create(:contract_membership, user_id: user.id, contract_id: contract.id) }
    before do
      travel_to Time.zone.local(2023, 5, 10, 3, 0, 0)
      allow(Contracts::ContractDomain).to receive(:show)
    end
    context '正常系' do
      let!(:resource) { Resource.find_by(name: 'contract') }
      context '正しいパラメータを受け取った場合' do
        it 'Contracts::ContractDomain.showが呼ばれること' do
          ContractService.show(token, target_user.id)
          expect(Contracts::ContractDomain).to have_received(:show).with(target_user.id)
        end
      end
      context 'admin権限を持っている場合' do
        let!(:resource) { Resource.find_by(name: 'admin') }
        it 'Contracts::ContractDomain.showが呼ばれること' do
          ContractService.show(token, target_user.id)
          expect(Contracts::ContractDomain).to have_received(:show).with(target_user.id)
        end
      end
    end
    context '異常系' do
      context 'tokenがなかった場合' do
        let!(:resource) { Resource.find_by(name: 'contract') }
        it 'ArgumentErrorが発生すること' do
          expect { ContractService.show(nil, target_user.id) }.to raise_error(ArgumentError)
        end
      end
      context 'target_user_idがなかった場合' do
        let!(:resource) { Resource.find_by(name: 'contract') }
        it 'ArgumentErrorが発生すること' do
          expect { ContractService.show(token, nil) }.to raise_error(ArgumentError)
        end
      end
      context '権限がなかった場合' do
        let!(:resource) { Resource.find_by(name: 'user') }
        it 'Forbiddenが発生すること' do
          expect { ContractService.show(token, target_user.id) }.to raise_error(Contracts::ContractsError::Forbidden)
        end
      end
    end
  end

  describe '#self.index' do
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
    let!(:contract) { create(:contract, user_id: user.id) }
    let!(:contract_membership) { create(:contract_membership, user_id: user.id, contract_id: contract.id) }
    before do
      travel_to Time.zone.local(2023, 5, 10, 3, 0, 0)
      allow(Contracts::ContractDomain).to receive(:index)
    end
    context '正常系' do
      let!(:resource) { Resource.find_by(name: 'contract') }
      context '正しいパラメータを受け取った場合' do
        it 'Contracts::ContractDomain.indexが呼ばれること' do
          ContractService.index(token)
          expect(Contracts::ContractDomain).to have_received(:index)
        end
      end
      context 'admin権限を持っている場合' do
        let!(:resource) { Resource.find_by(name: 'admin') }
        it 'Contracts::ContractDomain.indexが呼ばれること' do
          ContractService.index(token)
          expect(Contracts::ContractDomain).to have_received(:index)
        end
      end
    end
    context '異常系' do
      context 'tokenがなかった場合' do
        let!(:resource) { Resource.find_by(name: 'contract') }
        it 'ArgumentErrorが発生すること' do
          expect { ContractService.index(nil) }.to raise_error(ArgumentError)
        end
      end
      context '権限がなかった場合' do
        let!(:resource) { Resource.find_by(name: 'user') }
        it 'Forbiddenが発生すること' do
          expect { ContractService.index(token) }.to raise_error(Contracts::ContractsError::Forbidden)
        end
      end
    end
  end

  describe '#self.update' do
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
    let!(:target_user) { create(:user, activated: true) }
    let!(:contract) { create(:contract, user_id: user.id) }
    let!(:contract_membership) { create(:contract_membership, user_id: user.id, contract_id: contract.id) }
    before do
      travel_to Time.zone.local(2023, 5, 10, 3, 0, 0)
      allow(Contracts::ContractDomain).to receive(:update)
    end
    context '正常系' do
      let!(:resource) { Resource.find_by(name: 'contract') }
      context '正しいパラメータを受け取った場合' do
        let!(:max_member_count) { 10 }
        it 'Contracts::ContractDomain.updateが呼ばれること' do
          ContractService.update(token, target_user.id, max_member_count)
          expect(Contracts::ContractDomain).to have_received(:update).with(target_user.id, max_member_count)
        end
      end
      context 'admin権限を持っている場合' do
        let!(:resource) { Resource.find_by(name: 'admin') }
        let!(:max_member_count) { 10 }
        it 'Contracts::ContractDomain.updateが呼ばれること' do
          ContractService.update(token, target_user.id, max_member_count)
          expect(Contracts::ContractDomain).to have_received(:update).with(target_user.id, max_member_count)
        end
      end
    end
    context '異常系' do
      context 'tokenがなかった場合' do
        let!(:resource) { Resource.find_by(name: 'contract') }
        let!(:max_member_count) { 10 }
        it 'ArgumentErrorが発生すること' do
          expect { ContractService.update(nil, target_user.id, max_member_count) }.to raise_error(ArgumentError)
        end
      end
      context 'target_user_idがなかった場合' do
        let!(:resource) { Resource.find_by(name: 'contract') }
        let!(:max_member_count) { 10 }
        it 'ArgumentErrorが発生すること' do
          expect { ContractService.update(token, nil, max_member_count) }.to raise_error(ArgumentError)
        end
      end
      context 'max_member_countがなかった場合' do
        let!(:resource) { Resource.find_by(name: 'contract') }
        it 'ArgumentErrorが発生すること' do
          expect { ContractService.update(token, target_user.id, nil) }.to raise_error(ArgumentError)
        end
      end
      context '権限がなかった場合' do
        let!(:resource) { Resource.find_by(name: 'user') }
        let!(:max_member_count) { 10 }
        it 'Forbiddenが発生すること' do
          expect { ContractService.update(token, target_user.id, max_member_count) }.to raise_error(Contracts::ContractsError::Forbidden)
        end
      end
    end
  end

  describe '#self.destroy' do
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
    let!(:target_user) { create(:user, activated: true) }
    let!(:contract) { create(:contract, user_id: user.id) }
    let!(:contract_membership) do
      create(:contract_membership, user_id: target_user.id, contract_id: contract.id)
    end
    before do
      travel_to Time.zone.local(2023, 5, 10, 3, 0, 0)
      allow(Contracts::ContractDomain).to receive(:destroy)
    end
    context '正常系' do
      let!(:resource) { Resource.find_by(name: 'contract') }
      context '正しいパラメータを受け取った場合' do
        it 'Contracts::ContractDomain.destroyが呼ばれること' do
          ContractService.destroy(token, target_user.id)
          expect(Contracts::ContractDomain).to have_received(:destroy).with(target_user.id)
        end
      end
      context 'admin権限を持っている場合' do
        let!(:resource) { Resource.find_by(name: 'admin') }
        it 'Contracts::ContractDomain.destroyが呼ばれること' do
          ContractService.destroy(token, target_user.id)
          expect(Contracts::ContractDomain).to have_received(:destroy).with(target_user.id)
        end
      end
    end
    context '異常系' do
      context 'tokenがなかった場合' do
        let!(:resource) { Resource.find_by(name: 'contract') }
        let!(:target_user) { create(:user, activated: true) }
        it 'ArgumentErrorが発生すること' do
          expect { ContractService.destroy(nil, target_user.id) }.to raise_error(ArgumentError)
        end
      end
      context 'target_user_idがなかった場合' do
        let!(:resource) { Resource.find_by(name: 'contract') }
        it 'ArgumentErrorが発生すること' do
          expect { ContractService.destroy(token, nil) }.to raise_error(ArgumentError)
        end
      end
      context '権限がなかった場合' do
        let!(:resource) { Resource.find_by(name: 'user') }
        it 'Forbiddenが発生すること' do
          expect { ContractService.destroy(token, target_user.id) }.to raise_error(Contracts::ContractsError::Forbidden)
        end
      end
    end
  end
end
