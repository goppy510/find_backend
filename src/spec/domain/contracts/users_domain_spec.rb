# frozen_string_literal: true

require 'rails_helper'
require 'rspec-rails'
require 'faker'

describe Contracts::UsersDomain do
  include SessionModule

  describe '#self.show' do
    before do
      travel_to Time.zone.local(2023, 5, 10, 3, 0, 0)
      allow(ContractMembershipRepository).to receive(:show)
    end
    context '正常系' do
      context '正しいuser_idとtarget_user_idを受け取った場合' do
        let!(:user) { create(:user, activated: true) }
        let!(:target_user) { create(:user, activated: true) }
        let!(:contract) { create(:contract, user_id: user.id) }
        let!(:contract_membership) { create(:contract_membership, user_id: target_user.id, contract_id: contract.id) }

        it 'ContractMembershipRepository.showが呼ばれること' do
          Contracts::UsersDomain.show(user.id, target_user.id)
          expect(ContractMembershipRepository).to have_received(:show).with(target_user.id, contract.id)
        end
      end
    end

    context '異常系' do
      context 'user_idが引数にない場合' do
        let!(:target_user) { create(:user, activated: true) }

        it 'ArgumentErrorがスローされること' do
          expect { Contracts::UsersDomain.show(nil, target_user.id) }.to raise_error(ArgumentError, 'user_idがありません')
        end
      end

      context 'target_user_idが引数にない場合' do
        let!(:user) { create(:user, activated: true) }

        it 'ArgumentErrorがスローされること' do
          expect { Contracts::UsersDomain.show(user.id, nil) }.to raise_error(ArgumentError, 'target_user_idがありません')
        end
      end

      context 'contract_idが存在しない場合' do
        let!(:user) { create(:user, activated: true) }
        let!(:target_user) { create(:user, activated: true) }

        it 'Forbbidenがスローされること' do
          expect { Contracts::UsersDomain.show(user.id, target_user.id) }.to raise_error(Contracts::ContractsError::Forbidden)
        end
      end
    end
  end

  describe '#self.index' do
    before do
      allow(ContractMembershipRepository).to receive(:index)
    end

    context '正常系' do
      context '正しいuser_idを受け取った場合' do
        let!(:user) { create(:user, activated: true) }
        let!(:contract) { create(:contract, user_id: user.id) }
        let!(:contract_membership) { create_list(:contract_membership, 5, contract_id: contract.id) }

        it 'ContractMembershipRepository.indexが呼ばれること' do
          Contracts::UsersDomain.index(user.id)
          expect(ContractMembershipRepository).to have_received(:index).with(contract.id)
        end
      end
    end

    context '異常系' do
      context 'user_idが引数にない場合' do
        it 'ArgumentErrorがスローされること' do
          expect { Contracts::UsersDomain.index(nil) }.to raise_error(ArgumentError, 'user_idがありません')
        end
      end

      context 'contract_idが存在しない場合' do
        let!(:user) { create(:user, activated: true) }

        it 'Forbbidenがスローされること' do
          expect { Contracts::UsersDomain.index(user.id) }.to raise_error(Contracts::ContractsError::Forbidden)
        end
      end
    end
  end

  describe '#self.destroy' do
    context '正常系' do
      context '正しいuser_idとtarget_user_idを受け取った場合' do
        let!(:user) { create(:user, activated: true) }
        let!(:target_user) { create(:user, activated: true) }
        let!(:contract) { create(:contract, user_id: user.id) }
        let!(:contract_membership) { create(:contract_membership, contract_id: contract.id, user_id: target_user.id) }

        it 'ContractMembershipRepositoryからtarget_userが削除されること' do
          Contracts::UsersDomain.destroy(user.id, target_user.id)
          expect(ContractMembership.find_by(user_id: target_user.id, contract_id: contract.id)).to be_nil
        end

        it 'usersテーブルからtarget_userが削除されること' do
          Contracts::UsersDomain.destroy(user.id, target_user.id)
          expect(User.find_by(id: target_user.id)).to be_nil
        end
      end
    end

    context '異常系' do
      context 'user_idが引数にない場合' do
        let!(:target_user) { create(:user, activated: true) }

        it 'ArgumentErrorがスローされること' do
          expect { Contracts::UsersDomain.destroy(nil, target_user.id) }.to raise_error(ArgumentError, 'user_idがありません')
        end
      end

      context 'target_user_idが引数にない場合' do
        let!(:user) { create(:user, activated: true) }

        it 'ArgumentErrorがスローされること' do
          expect { Contracts::UsersDomain.destroy(user.id, nil) }.to raise_error(ArgumentError, 'target_user_idがありません')
        end
      end

      context 'contract_idが存在しない場合' do
        let!(:user) { create(:user, activated: true) }
        let!(:target_user) { create(:user, activated: true) }

        it 'Forbbidenがスローされること' do
          expect { Contracts::UsersDomain.destroy(user.id, target_user.id) }.to raise_error(Contracts::ContractsError::Forbidden)
        end
      end

      context 'target_user_idがcontract_idに紐づいていない場合' do
        let!(:user) { create(:user, activated: true) }
        let!(:target_user) { create(:user, activated: true) }
        let!(:contract) { create(:contract, user_id: user.id) }
        let!(:other_user) { create(:user, activated: true) }
        let!(:other_contract) { create(:contract, user_id: other_user.id) }
        let!(:contract_membership) { create(:contract_membership, contract_id: other_contract.id, user_id: target_user.id) }

        it 'Forbiddenがスローされること' do
          expect { Contracts::UsersDomain.destroy(user.id, target_user.id) }.to raise_error(Contracts::ContractsError::Forbidden)
        end
      end
    end
  end
end
