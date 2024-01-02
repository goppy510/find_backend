# frozen_string_literal: true

require 'rails_helper'
require 'rspec-rails'
require 'faker'

describe Profiles::ProfileDomain do
  include SessionModule

  describe '#self.create' do
    context '正常系' do
      context '必要なすべてのパラメータを受け取った場合' do
        before do
          travel_to Time.zone.local(2023, 5, 10, 3, 0, 0)
        end

        let!(:user) { create(:user, activated: true) }
        let!(:profiles) do
          {
            profiles: {
              name: '田中 太郎',
              phone_number: '08012345678',
              company_name: '株式会社makelead',
              employee_count: 1,
              industry: 2,
              position: 3,
              business_model: 2
            }
          }
        end

        it 'profilesに登録されること' do
          Profiles::ProfileDomain.create(user.id, profiles)
          actual_data = Profile.find_by(user_id: user.id)
          expect(actual_data.full_name).to eq(profiles[:profiles][:name])
          expect(actual_data.phone_number).to eq(profiles[:profiles][:phone_number])
          expect(actual_data.company_name).to eq(profiles[:profiles][:company_name])
          expect(actual_data.employee_count_id).to eq(profiles[:profiles][:employee_count])
          expect(actual_data.industry_id).to eq(profiles[:profiles][:industry])
          expect(actual_data.position_id).to eq(profiles[:profiles][:position])
          expect(actual_data.business_model_id).to eq(profiles[:profiles][:business_model])
        end
      end
    end

    context '異常系' do
      before do
        travel_to Time.zone.local(2023, 5, 10, 3, 0, 0)
      end

      let!(:email) { Faker::Internet.email }
      let!(:password) { 'P@ssw0rd' }
      let!(:user) { create(:user, email:, password:, activated: true) }
      let!(:profiles) do
        {
          profile: {
            name: '田中 太郎',
            phone_number: '08012345678',
            company_name: '株式会社makelead',
            employee_count: 1,
            industry: 2,
            position: 3,
            business_model: 2
          }
        }
      end

      context 'user_idがない場合' do
        it 'ArgumentErrorがスローされること' do
          expect { Profiles::ProfileDomain.create(nil, profiles) }.to raise_error(ArgumentError, 'user_idがありません')
        end
      end

      context 'profilesがない場合' do
        it 'ArgumentErrorがスローされること' do
          expect { Profiles::ProfileDomain.create(user.id, {}) }.to raise_error(ArgumentError, 'profilesがありません')
        end
      end
    end
  end

  describe '#self.update' do
    context '正常系' do
      context '必要なすべてのパラメータを受け取った場合' do
        before do
          travel_to Time.zone.local(2023, 5, 10, 3, 0, 0)
        end
        let!(:email) { Faker::Internet.email }
        let!(:password) { 'P@ssw0rd' }
        let!(:user) { create(:user, email:, password:, activated: true) }
        let!(:current_profiles) { create(:profile, user_id: user.id) }
        let!(:new_profiles) do
          {
            profiles: {
              name: '田中 太郎',
              phone_number: '08012345678',
              employee_count: 1
            }
          }
        end

        it 'userのidでnew_profilesにあるものは更新され、それ以外は更新されないこと' do
          Profiles::ProfileDomain.update(user.id, new_profiles)
          profile = Profile.find_by(user_id: user.id)
          expect(profile.full_name).to eq(new_profiles[:profiles][:name])
          expect(profile.phone_number).to eq(new_profiles[:profiles][:phone_number])
          expect(profile.company_name).to eq(current_profiles[:company_name])
          expect(profile.employee_count_id).to eq(new_profiles[:profiles][:employee_count])
          expect(profile.position_id).to eq(current_profiles[:position_id])
          expect(profile.business_model_id).to eq(current_profiles[:business_model_id])
        end
      end
    end

    context '異常系' do
      before do
        travel_to Time.zone.local(2023, 5, 10, 3, 0, 0)
      end
      let!(:password) { 'P@ssw0rd' }
      let!(:user) { create(:user, password:, activated: true) }
      let!(:current_profiles) { create(:profile, user_id: user.id) }
      let!(:new_profiles) do
        {
          profiles: {
            name: '田中 太郎',
            phone_number: '08012345678',
            employee_count: 1
          }
        }
      end

      context 'user_idがない場合' do
        it 'ArgumentErrorがスローされること' do
          expect { Profiles::ProfileDomain.update(nil, profiles: new_profiles) }.to raise_error(ArgumentError, 'user_idがありません')
        end
      end

      context 'profilesがない場合' do
        it 'ArgumentErrorがスローされること' do
          expect { Profiles::ProfileDomain.update(user.id, nil) }.to raise_error(ArgumentError, 'profilesがありません')
        end
      end
    end
  end

  describe '#self.show' do
    context '正常系' do
      context '必要なすべてのパラメータを受け取った場合' do
        before do
          travel_to Time.zone.local(2023, 5, 10, 3, 0, 0)
        end
        let!(:user) { create(:user, activated: true) }
        let!(:profile) { create(:profile, user_id: user.id) }

        it 'profileのデータがハッシュで返されること' do
          res = Profiles::ProfileDomain.show(user.id)
          expect(res[:name]).to eq(profile.full_name)
          expect(res[:phone_number]).to eq(profile.phone_number)
          expect(res[:company_name]).to eq(profile.company_name)
          expect(res[:employee_count]).to eq(EmployeeCount.find(profile.employee_count_id).name)
          expect(res[:industry]).to eq(Industry.find(profile.industry_id).name)
          expect(res[:position]).to eq(Position.find(profile.position_id).name)
          expect(res[:business_model]).to eq(BusinessModel.find(profile.business_model_id).name)
        end
      end
    end

    context '異常系' do
      before do
        travel_to Time.zone.local(2023, 5, 10, 3, 0, 0)
      end

      context 'user_idがない場合' do
        it 'ArgumentErrorがスローされること' do
          expect { Profiles::ProfileDomain.show(nil) }.to raise_error(ArgumentError, 'user_idがありません')
        end
      end
    end
  end
end
