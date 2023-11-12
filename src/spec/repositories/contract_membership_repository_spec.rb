# frozen_string_literal: true

require 'rails_helper'
require 'rspec-rails'
require 'faker'

describe ContractMembershipRepository do
  describe '#self.create' do
    context '正常系' do
      context 'target_user_idとcontract_idを受け取った場合' do
        before do
          travel_to Time.zone.local(2023, 5, 10, 3, 0, 0)
        end

        let!(:user) { create(:user, activated: true) }
        let!(:target_user) { create(:user, activated: true) }
        let!(:contract) { create(:contract, user_id: user.id) }

        it 'contract_membershipsにインサートされること' do
          ContractMembershipRepository.create(target_user.id, contract.id)
          actual = ContractMembership.find_by(user_id: target_user.id, contract_id: contract.id)
          expect(actual.user_id).to eq(target_user.id)
          expect(actual.contract_id).to eq(contract.id)
        end
      end
    end
  end

  describe '#self.show' do
    context '該当するユーザーがレコードにある場合' do
      before do
        travel_to Time.zone.local(2023, 5, 10, 3, 0, 0)
      end

      let!(:user) { create(:user, activated: true) }
      let!(:target_user) { create(:user, activated: true) }
      let!(:contract) { create(:contract, user_id: user.id) }
      let!(:contract_membership) { create(:contract_membership, user_id: target_user.id, contract_id: contract.id) }

      it 'ContractMembershipオブジェクトが返ること' do
        actual = ContractMembershipRepository.show(target_user.id, contract.id)
        expect(actual.user_id).to eq(target_user.id)
        expect(actual.contract_id).to eq(contract.id)
      end
    end
  end

  describe '#self.index' do
    context '該当するユーザーがレコードにある場合' do
      before do
        travel_to Time.zone.local(2023, 5, 10, 3, 0, 0)
      end

      let!(:user) { create(:user, activated: true) }
      let!(:target_user_1) { create(:user, activated: true) }
      let!(:target_user_2) { create(:user, activated: true) }
      let!(:contract) { create(:contract, user_id: user.id) }
      let!(:contract_membership) do
        create(:contract_membership, user_id: target_user_1.id, contract_id: contract.id)
        create(:contract_membership, user_id: target_user_2.id, contract_id: contract.id)
      end

      it 'ContractMembershipオブジェクトが返ること' do
        actual = ContractMembershipRepository.index(contract.id)
        expect(actual[0].user_id).to eq(target_user_1.id)
        expect(actual[0].contract_id).to eq(contract.id)
        expect(actual[1].user_id).to eq(target_user_2.id)
        expect(actual[1].contract_id).to eq(contract.id)
      end
    end
  end

  describe '#self.destroy' do
    context '該当するユーザーがレコードにある場合' do
      before do
        travel_to Time.zone.local(2023, 5, 10, 3, 0, 0)
      end

      let!(:user) { create(:user, activated: true) }
      let!(:target_user) { create(:user, activated: true) }
      let!(:contract) { create(:contract, user_id: user.id) }
      let!(:contract_membership) { create(:contract_membership, user_id: target_user.id, contract_id: contract.id) }

      it 'ContractMembershipがnilで返ること' do
        ContractMembershipRepository.destroy(target_user.id, contract.id)
        actual = ContractMembership.find_by(user_id: target_user.id, contract_id: contract.id)
        expect(actual).to eq(nil)
      end
    end
  end
end
