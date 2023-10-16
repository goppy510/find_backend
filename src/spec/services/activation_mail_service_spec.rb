# frozen_string_literal: true

require 'rails_helper'
require 'rspec-rails'
require 'faker'

describe ActivationMailService do
  include SessionModule
  describe '#self.activation_email' do
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
        let!(:user) { create(:user, email:) }

        it 'メールが送られること' do
          service = ActivationMailService.new(email)
          service.activation_email
          expect(ActivationMailer).to have_received(:send_activation_email)
          expect(mailer).to have_received(:deliver)
        end
      end
    end

    context '異常系' do
      context 'emailがnilの場合' do
        it 'ArgumentErrorが発生すること' do
          expect { ActivationMailService.activation_email(nil) }.to raise_error(ArgumentError)
        end
      end

      context 'emailのフォーマットが不正な場合' do
        let!(:email) { 'test' }

        it 'EmailFormatErrorがスローされること' do
          expect { ActivationMailService.activation_email(email) }.to raise_error(ActivationMailService::EmailFormatError)
        end
      end

      context 'userがアクティベート済の場合' do
        before do
          travel_to Time.zone.local(2023, 5, 10, 3, 0, 0)
        end

        let!(:email) { Faker::Internet.email }
        let!(:password) { 'P@ssw0rd' }
        let!(:user) { create(:user, email:, password:, activated: true) }

        it 'Unauthorizedがスローされること' do
          expect { ActivationMailService.activation_email(email) }.to raise_error(ActivationMailService::Unauthorized)
        end
      end
    end
  end
end
