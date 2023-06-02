#frozen_string_literal: true

require 'rails_helper'

describe Api::Users::ActivationController, type: :request do
  include ActionController::Cookies
  include SessionModule

  describe "POST /api/users/activation" do
    context "正常系" do
      context '正しいtokenを受け取った場合' do
        let!(:email) { Faker::Internet.email }
        let!(:password) { 'P@ssw0rd' }
        let!(:user) { create(:user, email: email, password: password) }
        let!(:payload) do
          {
            sub: user.id,
            type: 'activation'
          }
        end
        let!(:auth) { generate_token(lifetime: Auth.token_signup_lifetime, payload: payload) } 

        let!(:token) { auth.token }

        before do
          travel_to Time.zone.local(2023, 05, 10, 3, 0, 0)
          post '/api/users/activation', headers: { "Authorization" => "Bearer #{token}" }
        end

        it "status_code: 200を返すこと" do
          expect(response).to have_http_status(200)
        end

        it "statusがsuccessであること" do
          expect(JSON.parse(response.body)["status"]).to eq("success")
        end

        it 'userのactivatedがtrueになっていること' do
          user = User.find_by(email: email)
          expect(user.activated).to be_truthy
        end
      end
    end

    context '異常系' do
      context "tokenがなかった場合" do
        let!(:email) { Faker::Internet.email }
        let!(:password) { 'P@ssw0rd' }
        let!(:user) { create(:user, email: email, password: password) }

        before do
          travel_to Time.zone.local(2023, 05, 10, 3, 0, 0)
          post '/api/users/activation', headers: { "Authorization" => "" }
        end

        it "status_code: 400を返すこと" do
          expect(response).to have_http_status(400)
        end

        it "codeがinvalid_parameterであること" do
          expect(JSON.parse(response.body)["error"]["code"]).to eq("invalid_parameter")
        end

        it 'userのactivatedがfalseのままであること' do
          user = User.find_by(email: email)
          expect(user.activated).to be_falsy
        end
      end

      context "不正なtokenだった場合" do
        let!(:email) { Faker::Internet.email }
        let!(:password) { 'P@ssw0rd' }
        let!(:user) { create(:user, email: email, password: password) }
        let!(:invalid_token) { 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c' }

        before do
          travel_to Time.zone.local(2023, 05, 10, 3, 0, 0)
          post '/api/users/activation', headers: { "Authorization" => "Bearer #{invalid_token}" }
        end

        it "status_code: 401を返すこと" do
          expect(response).to have_http_status(401)
        end

        it "codeがunauthorizedであること" do
          expect(JSON.parse(response.body)["error"]["code"]).to eq("unauthorized")
        end

        it 'userのactivatedがfalseのままであること' do
          user = User.find_by(email: email)
          expect(user.activated).to be_falsy
        end
      end

      context "tokenは正しいが該当するuserがなかった場合" do
        let!(:email) { Faker::Internet.email }
        let!(:password) { 'P@ssw0rd' }
        let!(:user) { create(:user, email: email, password: password) }
        let!(:payload) do
          {
            sub: 999,
            type: 'activation'
          }
        end
        let!(:auth) { generate_token(lifetime: Auth.token_signup_lifetime, payload: payload) } 
        let!(:token) { auth.token }

        before do
          travel_to Time.zone.local(2023, 05, 10, 3, 0, 0)
          post '/api/users/activation', headers: { "Authorization" => "Bearer #{token}" }
        end

        it "status_code: 401を返すこと" do
          expect(response).to have_http_status(401)
        end

        it "codeがnot_foundであること" do
          expect(JSON.parse(response.body)["error"]["code"]).to eq("unauthorized")
        end

        it 'userのactivatedがfalseのままであること' do
          user = User.find_by(email: email)
          expect(user.activated).to be_falsy
        end
      end
    end
  end
end
