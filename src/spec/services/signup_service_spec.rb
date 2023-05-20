#frozen_string_literal: true

require 'rails_helper'
require 'rspec-rails'
require 'faker'

describe SignupService do
  describe '#self.signup' do
    context '正常系' do
      context '正しいメールアドレスとパスワードを受け取った場合' do
        let!(:email) { Faker::Internet.email }
        let!(:password) { 'P@ssw0rd' }

        it 'usersにインサートされること' do
          SignupService.signup(email, password)
          user = User.find_by(email: email)
          expect(user.email).to eq(email)
          expect(user.authenticate(password)).to be_truthy
        end
      end
    end

    context '異常系' do
      context 'メールアドレスが引数にない場合' do
        let!(:password) { 'P@ssw0rd' }

        it 'ArgumentErrorがスローされること' do
          expect {  SignupService.signup(nil, password) }.to raise_error(ArgumentError, 'emailがありません')
        end
      end

      context 'パスワードが引数にない場合' do
        let!(:email) { Faker::Internet.email }

        it 'ArgumentErrorがスローされること' do
          expect {  SignupService.signup(email, nil) }.to raise_error(ArgumentError, 'passwordがありません')
        end
      end
    end
  end
end
