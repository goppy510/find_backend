#frozen_string_literal: true

require 'rails_helper'

describe Api::Users::SignupController, type: :request do
  include ActionController::Cookies

  describe "POST /api/users/signup" do
    context "正常系" do
      context '正しいパラメータを受け取った場合' do
        let!(:email) { Faker::Internet.email }
        let!(:password) { 'P@ssw0rd' }

        let!(:valid_params) do
          {
            email: email,
            password: password
          }
        end

        before do
          travel_to Time.zone.local(2023, 05, 10, 3, 0, 0)
          post '/api/users/signup', params: valid_params
        end

        it "status_code: 200を返すこと" do
          expect(response).to have_http_status(200)
        end

        it "statusがsuccessであること" do
          expect(JSON.parse(response.body)["status"]).to eq("success")
        end

        it 'usersにemailが登録されていること' do
          user = User.find_by(email: email)
          expect(user.email).to eq(email)
        end
      end
    end

    context '異常系' do
      context "パラメータがなかった場合" do
        let!(:email) { Faker::Internet.email }
        let!(:password) { 'P@ssw0rd' }

        context 'emailがなかった場合' do
          before do
            post '/api/users/signup', params: { email: email }
          end

          it "status_code: 400を返すこと" do
            expect(response).to have_http_status(400)
          end

          it "invalid_parameterを返すこと" do
            expect(JSON.parse(response.body)["error"]["code"]).to eq("invalid_parameter")
          end
        end

        context 'passwordがなかった場合' do
          before do
            post '/api/users/signup', params: { password: password }
          end

          it "status_code: 400を返すこと" do
            expect(response).to have_http_status(400)
          end

          it "invalid_parameterを返すこと" do
            expect(JSON.parse(response.body)["error"]["code"]).to eq("invalid_parameter")
          end
        end
      end
    end
  end
end
