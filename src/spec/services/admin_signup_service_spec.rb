# frozen_string_literal: true

require 'rails_helper'
require 'rspec-rails'
require 'faker'

describe AdminSignupService do
  include SessionModule

  before do
    travel_to Time.zone.local(2023, 5, 10, 3, 0, 0)
  end

  describe '#add' do
    let!(:user) { create(:user, activated: true) }
    let!(:payload) do
      {
        sub: user.id,
        type: 'api'
      }
    end
    let!(:auth) { generate_token(payload:) }
    let!(:token) { auth.token }
    let!(:contract_resource) { Resource.find_by(name: 'contract') }
    let!(:permission) { create(:permission, user_id: user.id, resource_id: contract_resource.id) }

    context '正常系' do
      context '正しいメールアドレスとパスワードを受け取った場合' do
        let!(:email) { Faker::Internet.email }
        let!(:password) { 'P@ssw0rd' }
        let!(:signups) do
          {
            signups: {
              email: email,
              password: password
            }
          }
        end

        it 'usersにメールアドレスとハッシュ化されたパスワードがインサートされること' do
          service = AdminSignupService.new(token, signups:)
          user = service.add
          expect(user.email).to eq(email)
          expect(user.authenticate(password)).to be_truthy
        end
      end
    end

    context '異常系' do
      context 'メールアドレスが引数にない場合' do
        let!(:password) { 'P@ssw0rd' }
        let!(:signups) do
          {
            signups: {
              email: nil,
              password: password
            }
          }
        end

        it 'ArgumentErrorがスローされること' do
          expect { AdminSignupService.new(token, signups:) }.to raise_error(ArgumentError, 'emailがありません')
        end
      end

      context 'パスワードが引数にない場合' do
        let!(:email) { Faker::Internet.email }
        let!(:signups) do
          {
            signups: {
              email: email,
              password: nil
            }
          }
        end

        it 'ArgumentErrorがスローされること' do
          expect { AdminSignupService.new(token, signups:) }.to raise_error(ArgumentError, 'passwordがありません')
        end
      end

      context 'メールアドレスが既に存在する場合' do
        let!(:email) { Faker::Internet.email }
        let!(:password) { 'P@ssw0rd' }
        let!(:signups) do
          {
            signups: {
              email: email,
              password: password
            }
          }
        end
        let!(:user_1) { create(:user, email:, password:) }

        it 'DuplicateEntryがスローされること' do
          service = AdminSignupService.new(token, signups:)
          expect { service.add }.to raise_error(AdminSignupService::DuplicateEntry)
        end
      end
    end
  end

  describe '#self.sigunp' do
    context '正常系' do
      before do
        allow(ContractRepository).to receive(:create)
      end
      context 'contract権限を持つユーザーが登録した場合' do
        context '存在するuserかつアクティベーションされていないuserの場合' do
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
          let!(:token) { auth.token }

          let!(:signups) do
            {
              signups: {
                email: email,
                password: password
              }
            }
          end

          it 'ContractService.createが呼ばれること' do
            AdminSignupService.signup(token, signups)
            expect(ContractRepository).to have_received(:create)
          end
        end
      end

      context 'contract権限を持たないユーザーが登録した場合' do
        context '存在するuserかつアクティベーションされていないuserの場合' do
          let!(:user) { create(:user, activated: true) }
          let!(:user_resource) { Resource.find_by(name: 'user') }
          let!(:permission) { create(:permission, user_id: user.id, resource_id: user_resource.id) }
          let!(:payload) do
            {
              sub: user.id,
              type: 'api'
            }
          end
          let!(:auth) { generate_token(payload:) }
          let!(:token) { auth.token }
          let!(:email) { Faker::Internet.email }
          let!(:password) { 'P@ssw0rd'}
          let!(:signups) do
            {
              signups: {
                email: email,
                password: password
              }
            }
          end

          it 'ContractService.createが呼ばれないこと' do
            begin
              AdminSignupService.signup(token, signups)
            rescue AdminSignupService::Forbidden
              expect(ContractRepository).not_to have_received(:create)
            end
          end

          it 'Forbiddenがraiseされること' do
            expect { AdminSignupService.signup(token, signups) }.to raise_error(AdminSignupService::Forbidden)
          end
        end
      end
    end

    context '異常系' do
      context 'emailが引数にない場合' do
        let!(:password) { 'P@ssw0rd' }
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
        let!(:token) { auth.token }
        let!(:signups) do
          {
            signups: {
              email: nil,
              password: password
            }
          }
        end

        it 'ArgumentErrorがスローされること' do
          expect { AdminSignupService.signup(token, signups) }.to raise_error(ArgumentError, 'emailがありません')
        end
      end

      context 'passwordが引数にない場合' do
        let!(:email) { Faker::Internet.email }
        let!(:user) { create(:user, activated: true) }
        let!(:user_resource) { Resource.find_by(name: 'contract') }
        let!(:permission) { create(:permission, user_id: user.id, resource_id: user_resource.id) }
        let!(:payload) do
          {
            sub: user.id,
            type: 'api'
          }
        end
        let!(:auth) { generate_token(payload:) }
        let!(:token) { auth.token }
        let!(:token) do
          {
            token: auth.token
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
          expect { AdminSignupService.signup(token, signups) }.to raise_error(ArgumentError, 'passwordがありません')
        end
      end

      context 'emailのフォーマットが不正な場合' do
        let!(:email) { 'test' }
        let!(:password) { 'P@ssw0rd' }
        let!(:user) { create(:user, activated: true) }
        let!(:user_resource) { Resource.find_by(name: 'contract') }
        let!(:permission) { create(:permission, user_id: user.id, resource_id: user_resource.id) }
        let!(:payload) do
          {
            sub: user.id,
            type: 'api'
          }
        end
        let!(:auth) { generate_token(payload:) }
        let!(:token) { auth.token }
        let!(:signups) do
          {
            signups: {
              email: email,
              password: password
            }
          }
        end

        it 'EmailFormatErrorがスローされること' do
          expect { AdminSignupService.signup(token, signups) }.to raise_error(AdminSignupService::EmailFormatError)
        end
      end

      context 'passwordのフォーマットが不正な場合' do
        let!(:email) { Faker::Internet.email }
        let!(:password) { 'test' }
        let!(:user) { create(:user, activated: true) }
        let!(:user_resource) { Resource.find_by(name: 'contract') }
        let!(:permission) { create(:permission, user_id: user.id, resource_id: user_resource.id) }
        let!(:payload) do
          {
            sub: user.id,
            type: 'api'
          }
        end
        let!(:auth) { generate_token(payload:) }
        let!(:token) { auth.token }
        let!(:signups) do
          {
            signups: {
              email: email,
              password: password
            }
          }
        end

        it 'PasswordFormatErrorがスローされること' do
          expect { AdminSignupService.signup(token, signups) }.to raise_error(AdminSignupService::PasswordFormatError)
        end
      end
    end
  end
end
