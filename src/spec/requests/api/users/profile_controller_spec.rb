# frozen_string_literal: true

require 'rails_helper'

describe Api::Users::ProfileController, type: :request do
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

  describe 'POST /api/users/profile' do
    context '正常系' do
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
          travel_to Time.zone.local(2023, 5, 10, 3, 0, 0)
          post '/api/users/profile', params: {}
        end
        it 'status_code: 400を返すこと' do
          expect(response).to have_http_status(400)
        end
        it 'ActionController::BadRequestを返すこと' do
          expect(JSON.parse(response.body)['error']['code']).to eq('ActionController::BadRequest')
        end
      end
    end
  end

  describe 'PUT /api/users/:id/profile' do
    context '正常系' do
      context '正しい更新用パラメータを受け取った場合' do
        let!(:current_profiles) { create(:profile, user_id: user.id) }
        let!(:new_profiles) do
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

        let!(:params) do
          {
            profiles: new_profiles
          }
        end

        before do
          travel_to Time.zone.local(2023, 5, 10, 3, 0, 0)
          put "/api/users/#{user.id}/profile", params:
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
          put "/api/users/#{user.id}/profile", params: {}
        end
        it 'status_code: 400を返すこと' do
          expect(response).to have_http_status(400)
        end
        it 'ActionController::BadRequestを返すこと' do
          expect(JSON.parse(response.body)['error']['code']).to eq('ActionController::BadRequest')
        end
      end
    end
  end

  describe 'PUT /api/users/:id/password' do
    context '正常系' do
      context '正しい現在のパスワードと更新用パスワードを受け取った場合' do
        let!(:current_password) { create(:profile, user_id: user.id) }
        let!(:new_password) { 'NewP@ssW0rd' }
        let!(:params) do
          {
            password: {
              'current_password': password,
              'new_password': new_password
            }
          }
        end

        before do
          travel_to Time.zone.local(2023, 5, 10, 3, 0, 0)
          put "/api/users/#{user.id}/password", params:
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
          put "/api/users/#{user.id}/password", params: {}
        end
        it 'status_code: 400を返すこと' do
          expect(response).to have_http_status(400)
        end
        it 'ActionController::BadRequestを返すこと' do
          expect(JSON.parse(response.body)['error']['code']).to eq('ActionController::BadRequest')
        end
      end
    end
  end

  describe 'GET /api/users/profile' do
    context '正常系' do
      context '正しいuser_idを受け取った場合' do
        let!(:profile) { create(:profile, user_id: user.id) }
        before do
          travel_to Time.zone.local(2023, 5, 10, 3, 0, 0)
          get '/api/users/profile'
        end

        it 'jsonであること' do
          expect(response.content_type).to eq('application/json; charset=utf-8')
        end
        it 'jsonでprofilesの中身を受け取ること' do
          expect(JSON.parse(response.body)).to eq(
            'data' => {
              'user_id' => user.id,
              'name' => profile.full_name,
              'phone_number' => profile.phone_number,
              'company_name' => profile.company_name,
              'employee_count' => EmployeeCount.find(profile[:employee_count_id]).name,
              'industry' => Industry.find(profile[:industry_id]).name,
              'position' => Position.find(profile[:position_id]).name,
              'business_model' => BusinessModel.find(profile[:business_model_id]).name
            },
            'status' => 'success'
          )
        end
        it 'status_code: okを返すこと' do
          expect(response).to have_http_status(:ok)
        end
        it 'statusがsuccessであること' do
          expect(JSON.parse(response.body)['status']).to eq('success')
        end
      end
    end
  end
end
