# frozen_string_literal: true

require 'rails_helper'
require 'rspec-rails'
require 'faker'

describe PermissionRepository do
  before do
    travel_to Time.zone.local(2023, 5, 10, 3, 0, 0)
  end
  let!(:user) { create(:user, activated: true) }
  let!(:target_user) { create(:user, activated: false) }

  describe '#self.create' do
    context '正常系' do
      context 'user_idと存在するpermissionsを受け取った場合' do
        it 'target_user_idがインサートされること' do
          ContractRepository.create(target_user.id)
          actual = Contract.where(user_id: target_user.id)
          expect(actual.length).to eq(1)
          expect(actual).to include( have_attributes(user_id: target_user.id ) )
          expect(actual).to include( have_attributes(max_member_count: 5 ) )
        end
      end
    end
  end

  describe '#self.show' do
    context '正常系' do
      context 'target_user_idを受け取った場合' do
        let!(:target_user_contract) { create(:contract, user_id: target_user.id) }
        it 'target_user_idに紐づくContractオブジェクトが返ること' do
          actual = ContractRepository.show(target_user.id)
          expect(actual.user_id).to eq(target_user.id)
          expect(actual.max_member_count).to eq(5)
        end
      end
    end
  end

  describe '#self.index' do
    context '正常系' do
      let!(:target_user_contract) { create(:contract, user_id: target_user.id) }
      let!(:target_user_2) { create(:user, activated: false) }
      let!(:target_user_2_contract) { create(:contract, user_id: target_user_2.id) }
      let!(:target_user_3) { create(:user, activated: false) }
      let!(:target_user_3_contract) { create(:contract, user_id: target_user_3.id) }

      context '正しいデータが入っている場合受け取った場合' do
        it 'すべてのContractオブジェクトが返ること' do
          actual = ContractRepository.index
          expect(actual.length).to eq(3)
          expect(actual).to include( have_attributes(user_id: target_user.id ) )
          expect(actual).to include( have_attributes(user_id: target_user_2.id ) )
          expect(actual).to include( have_attributes(user_id: target_user_3.id ) )
        end
      end
    end
  end

  describe '#self.destroy' do
    context '正常系' do
      let!(:target_user_contract) { create(:contract, user_id: target_user.id) }
      context '正しいtarget_user_idを受け取った場合' do
        it 'target_user_idに紐づくContractオブジェクトが削除されること' do
          ContractRepository.destroy(target_user.id)
          actual = Contract.where(user_id: target_user.id)
          expect(actual.length).to eq(0)
        end
        it 'target_userは消えないこと' do
          ContractRepository.destroy(target_user.id)
          actual = User.where(id: target_user.id)
          expect(actual.length).to eq(1)
        end
      end
    end
  end
end
