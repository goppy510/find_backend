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
        let!(:signups) do
          {
            signups: {
              email: email,
              password: password
            }
          }
        end

        it 'usersにメールアドレスとハッシュ化されたパスワードがインサートされること' do
          service = Signup::UserSignupDomain.new(signups:)
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
          expect { Signup::UserSignupDomain.new(signups:) }.to raise_error(ArgumentError, 'emailがありません')
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
          expect { Signup::UserSignupDomain.new(signups:) }.to raise_error(ArgumentError, 'passwordがありません')
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
        let!(:user) { create(:user, email:, password:) }

        it 'DuplicateEntryがスローされること' do
          service = Signup::UserSignupDomain.new(signups:)
          expect { service.add }.to raise_error(Signup::UserSignupDomain::DuplicateEntry)
        end
      end
    end
  end

  describe '#self.sigunp' do
    context '正常系' do
      context '存在するuserかつアクティベーションされていないuserの場合' do
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

        it 'activation_emailが呼ばれること' do
          Signup::UserSignupDomain.signup(signups)
          expect(ActivationMailService).to have_received(:activation_email).with(email)
        end
      end
    end

    context '異常系' do
      context 'emailが引数にない場合' do
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
          expect { Signup::UserSignupDomain.signup(signups) }.to raise_error(ArgumentError, 'emailがありません')
        end
      end

      context 'passwordが引数にない場合' do
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
          expect { Signup::UserSignupDomain.signup(signups) }.to raise_error(ArgumentError, 'passwordがありません')
        end
      end

      context 'emailのフォーマットが不正な場合' do
        let!(:email) { 'test' }
        let!(:password) { 'P@ssw0rd' }
        let!(:signups) do
          {
            signups: {
              email: email,
              password: password
            }
          }
        end

        it 'EmailFormatErrorがスローされること' do
          expect { Signup::UserSignupDomain.signup(signups) }.to raise_error(Signup::UserSignupDomain::EmailFormatError)
        end
      end

      context 'passwordのフォーマットが不正な場合' do
        let!(:email) { Faker::Internet.email }
        let!(:password) { 'test' }
        let!(:signups) do
          {
            signups: {
              email: email,
              password: password
            }
          }
        end

        it 'PasswordFormatErrorがスローされること' do
          expect { Signup::UserSignupDomain.signup(signups) }.to raise_error(Signup::UserSignupDomain::PasswordFormatError)
        end
      end
    end
  end
end
