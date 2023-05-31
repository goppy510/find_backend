#frozen_string_literal: true

require 'rails_helper'

describe Api::Users::LoginController, type: :request do
  include ActionController::Cookies

  describe "POST /api/users/login" do
    context "正常系" do
      context '正しいパラメータを受け取った場合' do
        let!(:email) { Faker::Internet.email }
        let!(:password) { 'P@ssw0rd' }
        let!(:user1) { create(:user, email: email, password: password, activated: true) }
        let!(:user2) { create(:user, activated: true) }
        let!(:profile) { create(:profile, user_id: user1.id ) }

        let!(:valid_params) do
          {
            email: email,
            password: password
          }
        end

        before do
          travel_to Time.zone.local(2023, 05, 10, 3, 0, 0)
          post '/api/users/login', params: valid_params
        end

        it "status_code: 200を返すこと" do
          expect(response).to have_http_status(200)
        end

        it "statusがsuccessであること" do
          expect(JSON.parse(response.body)["status"]).to eq("success")
        end

        it 'cookieにパラメータが保存されていること' do
          cookie = response.headers['Set-Cookie']
          cookie_parts = cookie.split("; ")
          expires_part = cookie_parts.find { |part| part.start_with?("expires=") }
          expires = DateTime.parse(expires_part.gsub("expires=", ""))
          expect(expires).to eq(Time.zone.local(2023, 05, 24, 3, 0, 0))
        end

        let!(:expected_response) do
          { "status" => "success", "data" => { "user_id" => user1.id, "exp" => Time.zone.local(2023, 05, 24, 3, 0, 0).to_i } }
        end      
        it 'responseに当該のuser.idとexpが記載されていること' do
          expect(JSON.parse(response.body)).to eq(expected_response)
        end
      end
    end

    context '異常系' do
      context "パラメータがなかった場合" do
        before do
          post '/api/users/login', params: {}
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

  describe "DELETE /destroy" do
    context "when logged in" do
      before do
        post '/api/login', params: { email: "test@example.com", password: "password" }
        delete '/api/logout'
      end

      it "returns a 200 status code" do
        expect(response).to have_http_status(200)
      end
    end
  end
end
