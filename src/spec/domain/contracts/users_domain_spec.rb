# frozen_string_literal: true

require 'rails_helper'
require 'rspec-rails'
require 'faker'

describe Contracts::UsersDomain do
  include SessionModule

  before do
    travel_to Time.zone.local(2023, 5, 10, 3, 0, 0)
    allow(ContractMembershipRepository).to receive(:create)
    allow(ContractMembershipRepository).to receive(:show)
    allow(ContractMembershipRepository).to receive(:destroy)
  end

  describe '#self.show' do
    context '正常系' do
      context '正しいuser_idとtarget_user_idを受け取った場合' do
        let!(:user) { create(:user, activated: true) }
        let!(:target_user) { create(:user, activated: true) }
        let!(:contract) { create(:contract, user_id: user.id) }
        let!(:contract_membership) { create(:contract_membership, contract_id: contract.id) }

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
          expect { Contracts::UsersDomain.show(user.id, target_user.id) }.to raise_error(Contracts::ContractsError::Forbbiden)
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
          expect { Contracts::UsersDomain.index(user.id) }.to raise_error(Contracts::ContractsError::Forbbiden)
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
        let!(:contract_membership) { create(:contract_membership, contract_id: contract.id) }

        it 'ContractMembershipRepository.destroyが呼ばれること' do
          Contracts::UsersDomain.destroy(user.id, target_user.id)
          expect(ContractMembershipRepository).to have_received(:destroy).with(target_user.id, contract.id)
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
          expect { Contracts::UsersDomain.destroy(user.id, target_user.id) }.to raise_error(Contracts::ContractsError::Forbbiden)
        end
      end
    end
  end
end
