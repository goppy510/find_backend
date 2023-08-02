# frozen_string_literal: true

require 'rails_helper'
require 'rspec-rails'
require 'faker'

describe ProfileRepository do
  describe '#create' do
    context '正常系' do
      context 'user_idとprofilesを受け取った場合' do
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

        it 'userのidでprofilesにインサートされること' do
          profile = ProfileRepository.create(user.id, profiles)
          expect(profile.user_id).to eq(user.id)
          expect(profile.full_name).to eq(profiles[:name])
          expect(profile.phone_number).to eq(profiles[:phone_number])
          expect(profile.company_name).to eq(profiles[:company_name])
          expect(profile.employee_count.id).to eq(profiles[:employee_count])
          expect(profile.position.id).to eq(profiles[:position])
          expect(profile.business_model.id).to eq(profiles[:business_model])
        end
      end
    end
  end

  describe '#find_by_user_id' do
    context '該当するユーザーがレコードにある場合' do
      before do
        travel_to Time.zone.local(2023, 5, 10, 3, 0, 0)
      end

      let!(:email) { Faker::Internet.email }
      let!(:password) { 'P@ssw0rd' }
      let!(:user) { create(:user, email:, password:, activated: true) }
      let!(:profile) { create(:profile, user_id: user.id) }

      it 'Profileオブジェクトが返ること' do
        actual = ProfileRepository.find_by_user_id(user.id)
        expect(actual.user_id).to eq(profile.user_id)
        expect(actual.company_name).to eq(profile.company_name)
      end
    end
  end
end
