# frozen_string_literal: true

require 'rails_helper'
require 'rspec-rails'
require 'faker'

describe Contracts::ContractDomain do
  include SessionModule

  describe '#self.create' do
    before do
      travel_to Time.zone.local(2023, 5, 10, 3, 0, 0)
      allow(ContractRepository).to receive(:create)
    end
    
    context '正常系' do
      context '正しいtarget_user_idとmax_member_countを受け取った場合' do
        let!(:target_user) { create(:user, activated: true) }
        let!(:max_member_count) { 10 }
        it 'ContractRepository.createが呼ばれること' do
          allow(ContractRepository).to receive(:create)
          Contracts::ContractDomain.create(target_user.id, max_member_count)
          expect(ContractRepository).to have_received(:create).with(target_user.id, max_member_count)
        end
      end
    end
    context '異常系' do
      context 'target_user_idが引数にない場合' do
        let!(:max_member_count) { 10 }
        it 'ArgumentErrorがスローされること' do
          expect { Contracts::ContractDomain.create(nil, max_member_count) }.to raise_error(ArgumentError, 'target_user_idがありません')
        end
      end
      context 'max_member_countが引数にない場合' do
        let!(:target_user) { create(:user, activated: true) }
        it 'ArgumentErrorがスローされること' do
          expect { Contracts::ContractDomain.create(target_user.id, nil) }.to raise_error(ArgumentError, 'max_member_countがありません')
        end
      end
    end
  end

  describe '#self.show' do
    before do
      travel_to Time.zone.local(2023, 5, 10, 3, 0, 0)
      allow(ContractRepository).to receive(:show)
    end
    context '正常系' do
      context '正しいuser_idとtarget_user_idを受け取った場合' do
        let!(:target_user) { create(:user, activated: true) }
        let!(:contract) { create(:contract, user_id: target_user.id) }

        it 'ContractRepository.showが呼ばれること' do
          Contracts::ContractDomain.show(target_user.id)
          expect(ContractRepository).to have_received(:show).with(target_user.id)
        end
      end
    end
    context '異常系' do
      context 'target_user_idが引数にない場合' do
        let!(:target_user) { create(:user, activated: true) }
        it 'ArgumentErrorがスローされること' do
          expect { Contracts::ContractDomain.show(nil) }.to raise_error(ArgumentError, 'target_user_idがありません')
        end
      end
    end
  end

  describe '#self.index' do
    before do
      allow(ContractRepository).to receive(:index)
    end
    context '正常系' do
      let!(:user) { create(:user, activated: true) }
      let!(:contract) { create(:contract, user_id: user.id) }

      it 'ContractRepository.indexが呼ばれること' do
        Contracts::ContractDomain.index
        expect(ContractRepository).to have_received(:index)
      end
    end
  end

  describe '#self.update' do
    before do
      travel_to Time.zone.local(2023, 5, 10, 3, 0, 0)
      allow(ContractRepository).to receive(:update)
    end
    context '正常系' do
      context '正しいuser_idとtarget_user_idを受け取った場合' do
        let!(:target_user) { create(:user, activated: true) }
        let!(:contract) { create(:contract, user_id: target_user.id) }
        it 'ContractRepository.updateが呼ばれること' do
          Contracts::ContractDomain.update(target_user.id, 10)
          expect(ContractRepository).to have_received(:update).with(target_user.id, 10)
        end
      end
    end
    context '異常系' do
      context 'target_user_idが引数にない場合' do
        let!(:target_user) { create(:user, activated: true) }
        it 'ArgumentErrorがスローされること' do
          expect { Contracts::ContractDomain.update(nil, 5) }.to raise_error(ArgumentError, 'target_user_idがありません')
        end
      end
      context 'max_member_countが存在しない場合' do
        let!(:user) { create(:user, activated: true) }
        let!(:target_user) { create(:user, activated: true) }
        it 'Forbbidenがスローされること' do
          expect { Contracts::ContractDomain.update(target_user.id, nil) }.to raise_error(ArgumentError, 'max_member_countがありません')
        end
      end
    end
  end

  describe '#self.destroy' do
    subject { Contracts::ContractDomain.destroy(target_user.id) }
    context '正常系' do
      context '正しいtarget_user_idを受け取った場合' do
        let!(:target_user) { create(:user, activated: true) }
        let!(:contract) { create(:contract, user_id: target_user.id) }
        it 'Contractからtarget_userが削除されること' do
          subject
          expect(Contract.find_by(user_id: target_user.id)).to be_nil
        end
        it 'usersテーブルからtarget_userが削除されないこと' do
          subject
          expect(User.find_by(id: target_user.id)).to be_present
        end
      end
    end
    context '異常系' do
      context 'target_user_idが引数にない場合' do
        it 'ArgumentErrorがスローされること' do
          expect { Contracts::ContractDomain.destroy(nil) }.to raise_error(ArgumentError, 'target_user_idがありません')
        end
      end
    end
  end
end
