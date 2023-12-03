# frozen_string_literal: true

require 'rails_helper'
require 'rspec-rails'
require 'faker'

describe Signup::UserSignupDomain do
  include SessionModule
  before do
    travel_to Time.zone.local(2023, 5, 10, 3, 0, 0)
    allow(ActivationMailService).to receive(:activation_email)
  end
  describe '#add' do
    context '正常系' do
      context '正しいメールアドレスとパスワードを受け取った場合' do
        let!(:email) { Faker::Internet.email }
        let!(:password) { 'P@ssw0rd' }
        let!(:manager_user) { create(:user, activated: true) }
        let!(:contract) { create(:contract, user_id: manager_user.id) }
        let!(:payload) do
          {
            sub: manager_user.id,
            type: 'api'
          }
        end
        let!(:auth) { generate_token(payload:) }
        let!(:token) { auth.token }
        let!(:signups) do
          {
            signups: {
              email: email,
              password: password,
              user_id: manager_user.id
            }
          }
        end

        it 'usersにメールアドレスとハッシュ化されたパスワードがインサートされること' do
          domain = Signup::UserSignupDomain.new(signups:)
          user = domain.add
          expect_user = User.find_by(email: email)
          expect(expect_user.email).to eq(email)
          expect(expect_user.authenticate(password)).to be_truthy
        end

        it 'ContractMembershipに契約IDとユーザーIDがインサートされること' do
          domain = Signup::UserSignupDomain.new(signups:)
          user = domain.add
          expect_user = User.find_by(email: email)
          expect(expect_user.contract_memberships.first.contract_id).to eq(contract.id)
          expect(expect_user.contract_memberships.first.user_id).to eq(expect_user.id)
        end
      end
    end

    context '異常系' do
      context 'メールアドレスが引数にない場合' do
        let!(:password) { 'P@ssw0rd' }
        let!(:manager_user) { create(:user, activated: true) }
        let!(:contract) { create(:contract, user_id: manager_user.id) }
        let!(:payload) do
          {
            sub: manager_user.id,
            type: 'api'
          }
        end
        let!(:signups) do
          {
            signups: {
              email: nil,
              password: password,
              user_id: manager_user.id
            }
          }
        end

        it 'ArgumentErrorがスローされること' do
          expect { Signup::UserSignupDomain.new(signups:) }.to raise_error(ArgumentError, 'emailがありません')
        end
      end

      context 'パスワードが引数にない場合' do
        let!(:email) { Faker::Internet.email }
        let!(:manager_user) { create(:user, activated: true) }
        let!(:contract) { create(:contract, user_id: manager_user.id) }
        let!(:payload) do
          {
            sub: manager_user.id,
            type: 'api'
          }
        end
        let!(:signups) do
          {
            signups: {
              email: email,
              password: nil,
              user_id: manager_user.id
            }
          }
        end

        it 'ArgumentErrorがスローされること' do
          expect { Signup::UserSignupDomain.new(signups:) }.to raise_error(ArgumentError, 'passwordがありません')
        end
      end

      context 'メールアドレスが既に存在する場合' do
        let!(:email) { Faker::Internet.email }
        let!(:password) { 'P@ssw0rd' }
        let!(:manager_user) { create(:user, activated: true) }
        let!(:contract) { create(:contract, user_id: manager_user.id) }
        let!(:payload) do
          {
            sub: manager_user.id,
            type: 'api'
          }
        end
        let!(:signups) do
          {
            signups: {
              email: email,
              password: password,
              user_id: manager_user.id
            }
          }
        end
        let!(:user) { create(:user, email:, password:) }

        it 'DuplicateEntryがスローされること' do
          domain = Signup::UserSignupDomain.new(signups:)
          expect { domain.add }.to raise_error(Signup::UserSignupDomain::DuplicateEntry)
        end
      end
    end
  end

  describe '#self.sigunp' do
    context '正常系' do
      context '存在するuserかつアクティベーションされていないuserの場合' do
        let!(:email) { Faker::Internet.email }
        let!(:password) { 'P@ssw0rd' }
        let!(:manager_user) { create(:user, activated: true) }
        let!(:contract) { create(:contract, user_id: manager_user.id) }
        let!(:payload) do
          {
            sub: manager_user.id,
            type: 'api'
          }
        end
        let!(:signups) do
          {
            signups: {
              email: email,
              password: password,
              user_id: manager_user.id
            }
          }
        end

        it 'activation_emailが呼ばれること' do
          Signup::UserSignupDomain.signup(signups)
          expect(ActivationMailService).to have_received(:activation_email).with(email)
        end
      end
    end

    context '異常系' do
      context 'emailが引数にない場合' do
        let!(:password) { 'P@ssw0rd' }
        let!(:manager_user) { create(:user, activated: true) }
        let!(:contract) { create(:contract, user_id: manager_user.id) }
        let!(:payload) do
          {
            sub: manager_user.id,
            type: 'api'
          }
        end
        let!(:signups) do
          {
            signups: {
              email: nil,
              password: password,
              user_id: manager_user.id
            }
          }
        end

        it 'ArgumentErrorがスローされること' do
          expect { Signup::UserSignupDomain.signup(signups) }.to raise_error(ArgumentError, 'emailがありません')
        end
      end

      context 'passwordが引数にない場合' do
        let!(:email) { Faker::Internet.email }
        let!(:manager_user) { create(:user, activated: true) }
        let!(:contract) { create(:contract, user_id: manager_user.id) }
        let!(:payload) do
          {
            sub: manager_user.id,
            type: 'api'
          }
        end
        let!(:signups) do
          {
            signups: {
              email: email,
              password: nil,
              user_id: manager_user.id
            }
          }
        end

        it 'ArgumentErrorがスローされること' do
          expect { Signup::UserSignupDomain.signup(signups) }.to raise_error(ArgumentError, 'passwordがありません')
        end
      end

      context 'emailのフォーマットが不正な場合' do
        let!(:email) { 'test' }
        let!(:password) { 'P@ssw0rd' }
        let!(:manager_user) { create(:user, activated: true) }
        let!(:contract) { create(:contract, user_id: manager_user.id) }
        let!(:payload) do
          {
            sub: manager_user.id,
            type: 'api'
          }
        end
        let!(:signups) do
          {
            signups: {
              email: email,
              password: password,
              user_id: manager_user.id
            }
          }
        end

        it 'EmailFormatErrorがスローされること' do
          expect { Signup::UserSignupDomain.signup(signups) }.to raise_error(Signup::SignupError::EmailFormatError)
        end
      end

      context 'passwordのフォーマットが不正な場合' do
        let!(:email) { Faker::Internet.email }
        let!(:manager_user) { create(:user, activated: true) }
        let!(:contract) { create(:contract, user_id: manager_user.id) }
        let!(:payload) do
          {
            sub: manager_user.id,
            type: 'api'
          }
        end
        let!(:password) { 'test' }
        let!(:signups) do
          {
            signups: {
              email: email,
              password: password,
              user_id: manager_user.id
            }
          }
        end

        it 'PasswordFormatErrorがスローされること' do
          expect { Signup::UserSignupDomain.signup(signups) }.to raise_error(Signup::SignupError::PasswordFormatError)
        end
      end

      context 'user_idが引数にない場合' do
        let!(:email) { Faker::Internet.email }
        let!(:password) { 'P@ssw0rd' }
        let!(:manager_user) { create(:user, activated: true) }
        let!(:payload) do
          {
            sub: manager_user.id,
            type: 'api'
          }
        end
        let!(:signups) do
          {
            signups: {
              email: email,
              password: password,
              user_id: nil
            }
          }
        end

        it 'ArgumentErrorがスローされること' do
          expect { Signup::UserSignupDomain.signup(signups) }.to raise_error(ArgumentError, 'user_idがありません')
        end
      end
    end
  end
end
