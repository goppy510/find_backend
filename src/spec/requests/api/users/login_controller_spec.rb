# frozen_string_literal: true

require 'rails_helper'

describe Api::Users::LoginController, type: :request do
  include ActionController::Cookies

  describe 'POST /api/users/login' do
    context '正常系' do
      context '正しいパラメータを受け取った場合' do
        let!(:email) { Faker::Internet.email }
        let!(:password) { 'P@ssw0rd' }
        let!(:user1) { create(:user, email:, password:, activated: true) }
        let!(:user2) { create(:user, activated: true) }
        let!(:profile) { create(:profile, user_id: user1.id) }

        let!(:valid_params) do
          {
            email:,
            password:
          }
        end

        before do
          travel_to Time.zone.local(2023, 5, 10, 3, 0, 0)
          post '/api/users/login', params: valid_params
        end

        it 'status_code: okを返すこと' do
          expect(response).to have_http_status(:ok)
        end

        it 'statusがsuccessであること' do
          expect(JSON.parse(response.body)['status']).to eq('success')
        end

        it 'cookieにパラメータが保存されていること' do
          cookie = response.headers['Set-Cookie']
          cookie_parts = cookie.split('; ')
          expires_part = cookie_parts.find { |part| part.start_with?('expires=') }
          expires = DateTime.parse(expires_part.gsub('expires=', ''))
          expect(expires).to eq(Time.zone.local(2023, 5, 24, 3, 0, 0))
        end

        let!(:expected_response) do
          {
            'status' => 'success',
            'data' => { 'user_id' => user1.id, 'exp' => Time.zone.local(2023, 5, 24, 3, 0, 0).to_i }
          }
        end
        it 'responseに当該のuser.idとexpが記載されていること' do
          expect(JSON.parse(response.body)).to eq(expected_response)
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

  describe 'DELETE /api/users/destroy' do
    context '正常系' do
      context 'cookieが保存されている場合' do
        let!(:email) { Faker::Internet.email }
        let!(:password) { 'P@ssw0rd' }
        before do
          post '/api/users/login', params: { email:, password: }
          delete '/api/users/logout'
        end

        it 'status_code: okを返すこと' do
          expect(response).to have_http_status(:ok)
        end

        it 'cookieが削除されること' do
          expect(response.headers['Set-Cookie']).to be_blank
        end
      end
    end
  end
end
