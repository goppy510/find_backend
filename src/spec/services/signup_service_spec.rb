# frozen_string_literal: true

require 'rails_helper'
require 'rspec-rails'
require 'faker'

describe SignupService do
  include SessionModule
  describe '#add' do
    context '正常系' do
      context '正しいメールアドレスとパスワードを受け取った場合' do
        before do
          travel_to Time.zone.local(2023, 5, 10, 3, 0, 0)
        end

        let!(:email) { Faker::Internet.email }
        let!(:password) { 'P@ssw0rd' }
        let!(:token) do
          {
            token: nil
          }
        end
        let!(:signups) do
          {
            signups: {
              email: email,
              password: password
            }
          }
        end

        it 'usersにメールアドレスとハッシュ化されたパスワードがインサートされること' do
          service = SignupService.new(signups:, token:)
          user = service.add
          expect(user.email).to eq(email)
          expect(user.authenticate(password)).to be_truthy
        end
      end
    end

    context '異常系' do
      before do
        travel_to Time.zone.local(2023, 5, 10, 3, 0, 0)
      end

      context 'メールアドレスが引数にない場合' do
        let!(:password) { 'P@ssw0rd' }
        let!(:token) do
          {
            token: nil
          }
        end
        let!(:signups) do
          {
            signups: {
              email: nil,
              password: password
            }
          }
        end

        it 'ArgumentErrorがスローされること' do
          expect { SignupService.new(signups:, token:) }.to raise_error(ArgumentError, 'emailがありません')
        end
      end

      context 'パスワードが引数にない場合' do
        let!(:email) { Faker::Internet.email }
        let!(:token) do
          {
            token: nil
          }
        end
        let!(:signups) do
          {
            signups: {
              email: email,
              password: nil
            }
          }
        end

        it 'ArgumentErrorがスローされること' do
          expect { SignupService.new(signups:, token:) }.to raise_error(ArgumentError, 'passwordがありません')
        end
      end

      context 'メールアドレスが既に存在する場合' do
        let!(:email) { Faker::Internet.email }
        let!(:password) { 'P@ssw0rd' }
        let!(:token) do
          {
            token: nil
          }
        end
        let!(:signups) do
          {
            signups: {
              email: email,
              password: password
            }
          }
        end
        let!(:user) { create(:user, email:, password:) }

        it 'DuplicateEntryがスローされること' do
          service = SignupService.new(signups:, token:)
          expect { service.add }.to raise_error(SignupService::DuplicateEntry)
        end
      end
    end
  end

  describe '#activation_email' do
    context '正常系' do
      let!(:mailer) { double('ActionMailer') }
      before do
        allow(mailer).to receive(:deliver)
        allow(ActivationMailer).to receive(:send_activation_email).and_return(mailer)
      end

      context '存在するuserかつアクティベーションされていないuserの場合' do
        before do
          travel_to Time.zone.local(2023, 5, 10, 3, 0, 0)
        end

        let!(:email) { Faker::Internet.email }
        let!(:password) { 'P@ssw0rd' }
        let!(:user) { create(:user, email:, password:) }
        let!(:token) do
          {
            token: nil
          }
        end
        let!(:signups) do
          {
            signups: {
              email: email,
              password: password
            }
          }
        end

        it 'メールが送られること' do
          service = SignupService.new(signups:, token:)
          service.activation_email
          expect(ActivationMailer).to have_received(:send_activation_email)
          expect(mailer).to have_received(:deliver)
        end
      end
    end

    context '異常系' do
      context 'userがアクティベート済の場合' do
        before do
          travel_to Time.zone.local(2023, 5, 10, 3, 0, 0)
        end

        let!(:email) { Faker::Internet.email }
        let!(:password) { 'P@ssw0rd' }
        let!(:token) do
          {
            token: nil
          }
        end
        let!(:signups) do
          {
            signups: {
              email: email,
              password: password
            }
          }
        end
        let!(:user) { create(:user, email:, password:, activated: true) }

        it 'UserNotFoundがスローされること' do
          service = SignupService.new(signups:, token:)
          expect { service.activation_email }.to raise_error(SignupService::Unauthorized)
        end
      end
    end
  end

  describe '#self.sigunp' do
    context '正常系' do
      let!(:mailer) { double('ActionMailer') }
      before do
        allow(mailer).to receive(:deliver)
        allow(ActivationMailer).to receive(:send_activation_email).and_return(mailer)
      end

      context 'contract権限を持つユーザーが登録した場合' do
        context '存在するuserかつアクティベーションされていないuserの場合' do
          before do
            travel_to Time.zone.local(2023, 5, 10, 3, 0, 0)
          end

          let!(:user) { create(:user, activated: true) }
          let!(:contract_resource) { Resource.find_by(name: 'contract') }
          let!(:permission) { create(:permission, user_id: user.id, resource_id: contract_resource.id) }
          let!(:payload) do
            {
              sub: user.id,
              type: 'api'
            }
          end
          let!(:auth) { generate_token(payload:) }
  
          let!(:email) { Faker::Internet.email }
          let!(:password) { 'P@ssw0rd'}
          let!(:token) do
            {
              token: auth.token
            }
          end
          let!(:signups) do
            {
              signups: {
                email: email,
                password: password
              }
            }
          end

          it 'メールが送られないこと' do
            SignupService.signup(signups, token)
            expect(ActivationMailer).to_not have_received(:send_activation_email)
            expect(mailer).to_not have_received(:deliver)
          end
        end
      end

      context 'contract権限を持たないユーザーが登録した場合' do
        context '存在するuserかつアクティベーションされていないuserの場合' do
          before do
            travel_to Time.zone.local(2023, 5, 10, 3, 0, 0)
          end

          let!(:email) { Faker::Internet.email }
          let!(:password) { 'P@ssw0rd'}
          let!(:token) do
            {
              token: nil
            }
          end
          let!(:signups) do
            {
              signups: {
                email: email,
                password: password
              }
            }
          end

          it 'メールが送られること' do
            SignupService.signup(signups, token)
            expect(ActivationMailer).to have_received(:send_activation_email)
            expect(mailer).to have_received(:deliver)
          end
        end
      end
    end

    context '異常系' do
      context 'emailが引数にない場合' do
        let!(:password) { 'P@ssw0rd' }
        let!(:token) do
          {
            token: nil
          }
        end
        let!(:signups) do
          {
            signups: {
              email: nil,
              password: password
            }
          }
        end

        it 'ArgumentErrorがスローされること' do
          expect { SignupService.signup(signups, token) }.to raise_error(ArgumentError, 'emailがありません')
        end
      end

      context 'passwordが引数にない場合' do
        let!(:email) { Faker::Internet.email }
        let!(:token) do
          {
            token: nil
          }
        end
        let!(:signups) do
          {
            signups: {
              email: email,
              password: nil
            }
          }
        end

        it 'ArgumentErrorがスローされること' do
          expect { SignupService.signup(signups, token) }.to raise_error(ArgumentError, 'passwordがありません')
        end
      end

      context 'emailのフォーマットが不正な場合' do
        let!(:email) { 'test' }
        let!(:password) { 'P@ssw0rd' }
        let!(:token) do
          {
            token: nil
          }
        end
        let!(:signups) do
          {
            signups: {
              email: email,
              password: password
            }
          }
        end

        it 'EmailFormatErrorがスローされること' do
          expect { SignupService.signup(signups, token) }.to raise_error(SignupService::EmailFormatError)
        end
      end

      context 'passwordのフォーマットが不正な場合' do
        let!(:email) { Faker::Internet.email }
        let!(:password) { 'test' }
        let!(:token) do
          {
            token: nil
          }
        end
        let!(:signups) do
          {
            signups: {
              email: email,
              password: password
            }
          }
        end

        it 'PasswordFormatErrorがスローされること' do
          expect { SignupService.signup(signups, token) }.to raise_error(SignupService::PasswordFormatError)
        end
      end
    end
  end
end
