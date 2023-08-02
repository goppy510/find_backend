# frozen_string_literal: true

require 'rails_helper'
require 'rspec-rails'
require 'faker'

describe ProfileService do
  describe '#self.create' do
    context '正常系' do
      context '必要なすべてのパラメータを受け取った場合' do
        before do
          travel_to Time.zone.local(2023, 5, 10, 3, 0, 0)
        end

        let!(:email) { Faker::Internet.email }
        let!(:password) { 'P@ssw0rd' }
        let!(:user) { create(:user, email:, password:, activated: true) }
        let!(:profiles) do
          {
            name: '田中 太郎',
            phone_number: '08012345678',
            company_name: '株式会社makelead',
            employee_count: 1,
            industry: 2,
            position: 3,
            business_model: 2
          }
        end

        it 'profilesに登録されること' do
          ProfileService.create(user.id, profiles:)
          actual_data = Profile.find_by(user_id: user.id)
          expect(actual_data.full_name).to eq(profiles[:name])
          expect(actual_data.phone_number).to eq(profiles[:phone_number])
          expect(actual_data.company_name).to eq(profiles[:company_name])
          expect(actual_data.employee_count.id).to eq(profiles[:employee_count])
          expect(actual_data.industry.id).to eq(profiles[:industry])
          expect(actual_data.position.id).to eq(profiles[:position])
          expect(actual_data.business_model.id).to eq(profiles[:business_model])
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
          name: '田中 太郎',
          phone_number: '08012345678',
          company_name: '株式会社makelead',
          employee_count: 1,
          industry: 2,
          position: 3,
          business_model: 2
        }
      end

      context 'user_idがない場合' do
        it 'ArgumentErrorがスローされること' do
          expect { ProfileService.create(nil, profiles) }.to raise_error(ArgumentError, 'user_idがありません')
        end
      end

      context 'profilesがない場合' do
        it 'ArgumentErrorがスローされること' do
          expect { ProfileService.create(user.id, {}) }.to raise_error(ArgumentError, 'profilesがありません')
        end
      end
    end
  end
end
