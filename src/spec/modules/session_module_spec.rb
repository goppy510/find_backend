#frozen_string_literal: true

require 'rails_helper'
require 'rspec-rails'
require 'faker'

describe SessionModule do
  describe '#authenticate_user' do
    context '正常系' do
      context '正しいtokenを受け取った場合' do
        before do
          travel_to Time.zone.local(2023, 05, 10, 3, 0, 0)
        end

        let!(:email) { Faker::Internet.email }
        let!(:password) { 'P@ssw0rd' }

        let!(:dummy_signup_controller_class) {
          Class.new do
            include SessionModule

            def params
              {}
            end
          end
        }
        let!(:dummy_signup_controller) {
          controller = dummy_signup_controller_class.new
          allow(controller).to receive(:params).and_return({ email: email, password: password })
          controller
        }

        it 'usersにメールアドレスとハッシュ化されたパスワードがインサートされること' do
          dummy_signup_controller.signup
          user = UserRepository.find_by_email_not_activated(email)
          expect(user.email).to eq(email)
          expect(user.authenticate(password)).to be_truthy
        end
      end
    end
  end

  describe '#delete_cookie' do
    let(:dummy_class) do
      Class.new do
        include SessionModule
        def cookies
          @cookies ||= {}
        end
      end
    end
    let(:dummy_instance) { dummy_class.new }

    context '正常系' do
      context 'tokenがcookieに保存されている場合' do
        before do
          travel_to Time.zone.local(2023, 05, 10, 3, 0, 0)
          dummy_instance.cookies[Auth.token_access_key] = "TestCookie"
        end

        it 'JWTに関するcookieが削除されること' do
          allow(dummy_instance).to receive(:cookies).and_call_original
          dummy_instance.delete_cookie
          expect(dummy_instance).to have_received(:cookies)
          expect(dummy_instance.cookies[Auth.token_access_key]).to be_nil
        end
      end
    end
  end
end
