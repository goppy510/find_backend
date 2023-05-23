#frozen_string_literal: true

require 'rails_helper'
require 'rspec-rails'
require 'faker'

describe SignupService do
  describe '#signup' do
    context '正常系' do
      context '正しいメールアドレスとパスワードを受け取った場合' do
        before do
          travel_to Time.zone.local(2023, 05, 10, 3, 0, 0)
        end

        let!(:email) { Faker::Internet.email }
        let!(:password) { 'P@ssw0rd' }

        it 'usersにメールアドレスとハッシュ化されたパスワードがインサートされること' do
          service = SignupService.new(email, password)
          service.signup
          user = User.find_by(email: email)
          expect(user.email).to eq(email)
          expect(user.authenticate(password)).to be_truthy
        end

        it 'RegistrationTokensに当該ユーザーID、トークン、トークンの有効期限がインサートされること' do
          service = SignupService.new(email, password)
          service.signup
          user = User.find_by(email: email)
          registration_token = RegistrationToken.find_by(user_id: user.id)
          expect(registration_token.token).to_not eq nil
          expect(registration_token.expires_at).to eq(Time.zone.local(2023, 05, 10, 4, 0, 0))
        end
      end
    end

    context '異常系' do
      context 'メールアドレスが引数にない場合' do
        let!(:password) { 'P@ssw0rd' }

        it 'ArgumentErrorがスローされること' do
          expect {  SignupService.new(nil, password) }.to raise_error(ArgumentError, 'emailがありません')
        end
      end

      context 'パスワードが引数にない場合' do
        let!(:email) { Faker::Internet.email }

        it 'ArgumentErrorがスローされること' do
          expect {  SignupService.new(email, nil) }.to raise_error(ArgumentError, 'passwordがありません')
        end
      end

      context 'regitration_tokensへのインサートに失敗した場合' do
        let(:email) { 'test@example.com' }
        let(:password) { 'P@ssw0rd' }
    
        it 'usersとregistration_tokensにデータがインサートされないこと' do
          allow(RegistrationToken).to receive(:create!).and_raise(ActiveRecord::RecordInvalid)
          expect {
            SignupService.new(email, password).signup
          }.to raise_error(SignupError)
    
          # ユーザーと登録トークンが両方とも作成されていないことを確認する
          user = User.find_by(email: email)
          expect(user).to be_nil
          expect(RegistrationToken.count).to be_zero
        end
      end
    end
  end
end
