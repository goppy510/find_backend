# frozen_string_literal: true

require 'rails_helper'

describe Api::Users::ProfileController, type: :request do
  describe 'POST /api/users/profile' do
    context '正常系' do
      let!(:email) { Faker::Internet.email }
      let!(:password) { 'P@ssw0rd' }
      let!(:user) { create(:user, email:, password:, activated: true) }
      let!(:login_params) do
        {
          email:,
          password:
        }
      end

      before do
        travel_to Time.zone.local(2023, 5, 10, 3, 0, 0)
        post '/api/users/login', params: login_params
      end

      context '正しいパラメータを受け取った場合' do
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

        let!(:valid_params) do
          {
            profiles:
          }
        end

        before do
          travel_to Time.zone.local(2023, 5, 10, 3, 0, 0)
          post '/api/users/profile', params: valid_params
        end

        it 'status_code: okを返すこと' do
          expect(response).to have_http_status(:ok)
        end

        it 'statusがsuccessであること' do
          expect(JSON.parse(response.body)['status']).to eq('success')
        end
      end
    end

    context '異常系' do
      context 'パラメータがなかった場合' do
        before do
          post '/api/users/login', params: {}
        end

        it 'status_code: 400を返すこと' do
          expect(response).to have_http_status(400)
        end

        it 'invalid_parameterを返すこと' do
          expect(JSON.parse(response.body)['error']['code']).to eq('invalid_parameter')
        end
      end
    end
  end
end
