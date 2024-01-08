# frozen_string_literal: true

require 'rails_helper'
require 'rspec-rails'
require 'faker'

describe Signup::ContractSignupDomain do
  include SessionModule

  before do
    travel_to Time.zone.local(2023, 5, 10, 3, 0, 0)
  end

  describe '#add' do
    let!(:user) { create(:user, activated: true) }

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
          Signup::ContractSignupDomain.new(signups:).add
          user = User.find_by(email: email)
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
          expect { Signup::ContractSignupDomain.new(signups:) }.to raise_error(ArgumentError, 'emailがありません')
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
          expect { Signup::ContractSignupDomain.new(signups:) }.to raise_error(ArgumentError, 'passwordがありません')
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
          service = Signup::ContractSignupDomain.new(signups:)
          expect { service.add }.to raise_error(Signup::ContractSignupDomain::DuplicateEntry)
        end
      end
    end
  end

  describe '#self.sigunp' do
    context '正常系' do
      context '存在するuserかつアクティベーションされているuserの場合' do
        let!(:user) { create(:user, activated: true) }
        let!(:email) { Faker::Internet.email }
        let!(:password) { 'P@ssw0rd'}
        let!(:signups) do
          {
            signups: {
              email: email,
              password: password,
              max_member_count: 10
            }
          }
        end
        it 'userが作成されること' do
          Signup::ContractSignupDomain.signup(signups)
          user = User.find_by(email: email)
          expect(user.email).to eq(email)
          expect(user.authenticate(password)).to be_truthy
        end
        it 'contractsにuser_idとmax_member_countがインサートされること' do
          Signup::ContractSignupDomain.signup(signups)
          user = User.find_by(email: email)
          contract = Contract.find_by(user_id: user.id)
          expect(contract.user_id).to eq(user.id)
          expect(contract.max_member_count).to eq(10)
        end
      end

      context '存在しないuserの場合' do
        before do
          allow(ContractRepository).to receive(:create)
          mock = double('mock')
          allow(Signup::ContractSignupDomain).to receive(:new).and_return(mock)
          allow(mock).to receive(:add)
          allow(mock).to receive(:email).and_return(email) 
        end
        let!(:email) { Faker::Internet.email }
        let!(:password) { 'P@ssw0rd'}
        let!(:signups) do
          {
            signups: {
              email: email,
              password: password,
              max_member_count: 10
            }
          }
        end
        it 'ContractRepository.createが呼ばれないこと' do
          Signup::ContractSignupDomain.signup(signups)
          expect(ContractRepository).to_not have_received(:create)
        end
      end
    end

    context '異常系' do
      context 'emailが引数にない場合' do
        let!(:password) { 'P@ssw0rd' }
        let!(:user) { create(:user, activated: true) }
        let!(:signups) do
          {
            signups: {
              email: nil,
              password: password,
              max_member_count: 10
            }
          }
        end
        it 'ArgumentErrorがスローされること' do
          expect { Signup::ContractSignupDomain.signup(signups) }.to raise_error(ArgumentError, 'emailがありません')
        end
      end

      context 'passwordが引数にない場合' do
        let!(:email) { Faker::Internet.email }
        let!(:user) { create(:user, activated: true) }
        let!(:signups) do
          {
            signups: {
              email: email,
              password: nil,
              max_member_count: 10
            }
          }
        end
        it 'ArgumentErrorがスローされること' do
          expect { Signup::ContractSignupDomain.signup(signups) }.to raise_error(ArgumentError, 'passwordがありません')
        end
      end

      context 'max_member_countが引数にない場合' do
        let!(:email) { Faker::Internet.email }
        let!(:password) { 'P@ssw0rd' }
        let!(:user) { create(:user, activated: true) }
        let!(:signups) do
          {
            signups: {
              email: email,
              password: password,
              max_member_count: nil
            }
          }
        end
        it 'ArgumentErrorがスローされること' do
          expect { Signup::ContractSignupDomain.signup(signups) }.to raise_error(ArgumentError, 'max_member_countがありません')
        end
      end

      context 'emailのフォーマットが不正な場合' do
        let!(:email) { 'test' }
        let!(:password) { 'P@ssw0rd' }
        let!(:user) { create(:user, activated: true) }
        let!(:signups) do
          {
            signups: {
              email: email,
              password: password,
              max_member_count: 10
            }
          }
        end
        it 'EmailFormatErrorがスローされること' do
          expect { Signup::ContractSignupDomain.signup(signups) }.to raise_error(Signup::SignupError::EmailFormatError)
        end
      end

      context 'passwordのフォーマットが不正な場合' do
        let!(:email) { Faker::Internet.email }
        let!(:password) { 'test' }
        let!(:user) { create(:user, activated: true) }
        let!(:signups) do
          {
            signups: {
              email: email,
              password: password,
              max_member_count: 10
            }
          }
        end
        it 'PasswordFormatErrorがスローされること' do
          expect { Signup::ContractSignupDomain.signup(signups) }.to raise_error(Signup::SignupError::PasswordFormatError)
        end
      end
    end
  end
end
