#frozen_string_literal: true

require 'rails_helper'
require 'rspec-rails'
require 'faker'

describe SignupService do
  describe '#add' do
    context '正常系' do
      context '正しいメールアドレスとパスワードを受け取った場合' do
        before do
          travel_to Time.zone.local(2023, 05, 10, 3, 0, 0)
        end

        let!(:email) { Faker::Internet.email }
        let!(:password) { 'P@ssw0rd' }

        it 'usersにメールアドレスとハッシュ化されたパスワードがインサートされること' do
          service = SignupService.new(email, password)
          user = service.add
          expect(user.email).to eq(email)
          expect(user.authenticate(password)).to be_truthy
        end
      end
    end

    context '異常系' do
      context 'メールアドレスが引数にない場合' do
        let!(:password) { 'P@ssw0rd' }

        it 'ArgumentErrorがスローされること' do
          expect { SignupService.new(nil, password) }.to raise_error(ArgumentError, 'emailまたはpasswordがありません')
        end
      end

      context 'パスワードが引数にない場合' do
        let!(:email) { Faker::Internet.email }

        it 'ArgumentErrorがスローされること' do
          expect { SignupService.new(email, nil) }.to raise_error(ArgumentError, 'emailまたはpasswordがありません')
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
          travel_to Time.zone.local(2023, 05, 10, 3, 0, 0)
        end

        let!(:email) { Faker::Internet.email }
        let!(:password) { 'P@ssw0rd' }
        let!(:user) { create(:user, email: email, password: password) }

        it 'メールが送られること' do
          service = SignupService.new(email, password)
          service.activation_email
          expect(ActivationMailer).to have_received(:send_activation_email)
          expect(mailer).to have_received(:deliver)
        end
      end
    end

    context '異常系' do
      context 'userがアクティベート済の場合' do
        before do
          travel_to Time.zone.local(2023, 05, 10, 3, 0, 0)
        end

        let!(:email) { Faker::Internet.email }
        let!(:password) { 'P@ssw0rd' }
        let!(:user) { create(:user, email: email, password: password, activated: true) }

        it 'UserNotFoundがスローされること' do
          service = SignupService.new(email, password)
          expect { service.activation_email }.to raise_error(Unauthorized)
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

      context '存在するuserかつアクティベーションされていないuserの場合' do
        before do
          travel_to Time.zone.local(2023, 05, 10, 3, 0, 0)
        end

        let!(:email) { Faker::Internet.email }
        let!(:password) { 'P@ssw0rd' }

        it 'メールが送られること' do
          SignupService.signup(email, password)
          expect(ActivationMailer).to have_received(:send_activation_email)
          expect(mailer).to have_received(:deliver)
        end
      end
    end
  end
end
