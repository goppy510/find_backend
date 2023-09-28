# frozen_string_literal: true

require 'rails_helper'

describe Api::Users::SignupController, type: :request do
  include ActionController::Cookies

  describe 'POST /api/users/signup' do
    context '正常系' do
      context '正しいパラメータを受け取った場合' do
        let!(:email) { Faker::Internet.email }
        let!(:password) { 'P@ssw0rd' }
        let!(:params) do
          {
            signups: {
              email:,
              password:
            }
          }
        end

        before do
          travel_to Time.zone.local(2023, 5, 10, 3, 0, 0)
          post '/api/users/signup', params:
        end

        it 'status_code: okを返すこと' do
          expect(response).to have_http_status(:ok)
        end

        it 'statusがsuccessであること' do
          expect(JSON.parse(response.body)['status']).to eq('success')
        end

        it 'usersにemailが登録されていること' do
          user = User.find_by(email:)
          expect(user.email).to eq(email)
        end
      end
    end

    context '異常系' do
      context 'パラメータがなかった場合' do
        let!(:email) { Faker::Internet.email }
        let!(:password) { 'P@ssw0rd' }

        context 'emailがなかった場合' do
          let!(:params) do
            {
              signups: {
                email: nil,
                password:
              }
            }
          end
          before do
            post '/api/users/signup', params:
          end

          it 'status_code: 400を返すこと' do
            expect(response).to have_http_status(400)
          end

          it 'emailがありませんを返すこと' do
            expect(JSON.parse(response.body)['error']['code']).to eq('emailがありません')
          end
        end

        context 'passwordがなかった場合' do
          let!(:params) do
            {
              signups: {
                email:,
                password: nil
              }
            }
          end
          before do
            post '/api/users/signup', params:
          end

          it 'status_code: 400を返すこと' do
            expect(response).to have_http_status(400)
          end

          it 'passwordがありませんを返すこと' do
            expect(JSON.parse(response.body)['error']['code']).to eq('passwordがありません')
          end
        end
      end

      context 'emailが重複していた場合' do
        let!(:email) { Faker::Internet.email }
        let!(:password) { 'P@ssw0rd' }
        let!(:params) do
          {
            signups: {
              email:,
              password:
            }
          }
        end
        let!(:user) { create(:user, email:) }

        before do
          post '/api/users/signup', params:
        end

        it 'status_code: 409を返すこと' do
          expect(response).to have_http_status(409)
        end

        it 'SignupService::DuplicateEntryを返すこと' do
          expect(JSON.parse(response.body)['error']['code']).to eq('SignupService::DuplicateEntry')
        end
      end
    end
  end
end
