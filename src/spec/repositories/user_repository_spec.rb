# frozen_string_literal: true

require 'rails_helper'
require 'rspec-rails'
require 'faker'

describe UserRepository do
  describe '#create' do
    context '正常系' do
      context 'メールアドレスとパスワードを受け取った場合' do
        before do
          travel_to Time.zone.local(2023, 5, 10, 3, 0, 0)
        end

        let!(:email) { Faker::Internet.email }
        let!(:password) { 'P@ssw0rd' }

        it 'usersにメールアドレスとハッシュ化されたパスワードがインサートされること' do
          user = UserRepository.create(email, password)
          expect(user.email).to eq(email)
          expect(user.authenticate(password)).to be_truthy
        end
      end
    end
  end

  describe '#find_by_id' do
    context '該当するユーザーがレコードにある場合' do
      before do
        travel_to Time.zone.local(2023, 5, 10, 3, 0, 0)
      end

      let!(:email) { Faker::Internet.email }
      let!(:password) { 'P@ssw0rd' }
      let!(:user) { create(:user, email:, password:) }

      it 'Userオブジェクトが返ること' do
        actual_user = UserRepository.find_by_id(user.id)
        expect(actual_user.email).to eq(email)
        expect(actual_user.authenticate(password)).to be_truthy
      end
    end
  end

  describe '#find_by_email' do
    context '該当するユーザーがレコードにある場合' do
      before do
        travel_to Time.zone.local(2023, 5, 10, 3, 0, 0)
      end

      let!(:email) { Faker::Internet.email }
      let!(:password) { 'P@ssw0rd' }
      let!(:user) { create(:user, email:, password:) }

      it 'Userオブジェクトが返ること' do
        actual_user = UserRepository.find_by_email(email)
        expect(actual_user.email).to eq(email)
        expect(actual_user.authenticate(password)).to be_truthy
      end
    end
  end

  describe '#find_by_activated' do
    context 'アクティベート済の該当するユーザーがレコードにある場合' do
      before do
        travel_to Time.zone.local(2023, 5, 10, 3, 0, 0)
      end

      let!(:email) { Faker::Internet.email }
      let!(:password) { 'P@ssw0rd' }
      let!(:user) { create(:user, email:, password:, activated: true) }

      it 'Userオブジェクトが返ること' do
        actual_user = UserRepository.find_by_activated(email, password)
        expect(actual_user.email).to eq(email)
        expect(actual_user.authenticate(password)).to be_truthy
      end
    end

    context '異常系' do
      context 'アクティベート未のユーザーの場合' do
        before do
          travel_to Time.zone.local(2023, 5, 10, 3, 0, 0)
        end

        let!(:email) { Faker::Internet.email }
        let!(:password) { 'P@ssw0rd' }
        let!(:user) { create(:user, email:, password:, activated: false) }

        it 'nilが返ること' do
          actual_user = UserRepository.find_by_activated(email, password)
          expect(actual_user).to be_nil
        end
      end

      context 'パスワードがemailと紐づいていない場合' do
        before do
          travel_to Time.zone.local(2023, 5, 10, 3, 0, 0)
        end

        let!(:email) { Faker::Internet.email }
        let!(:password) { 'P@ssw0rd' }
        let!(:user) { create(:user, email:, password:, activated: false) }

        it 'nilが返ること' do
          actual_user = UserRepository.find_by_activated(email, 'hoge')
          expect(actual_user).to be_nil
        end
      end
    end
  end

  describe '#activate' do
    context 'アクティベート未の該当するユーザーがレコードにある場合' do
      before do
        travel_to Time.zone.local(2023, 5, 10, 3, 0, 0)
      end

      let!(:email) { Faker::Internet.email }
      let!(:password) { 'P@ssw0rd' }
      let!(:user) { create(:user, email:, password:, activated: false) }

      it 'Userのactivatedがtrueになること' do
        UserRepository.activate(user)
        actual_user = User.find(user.id) # DBから最新の状態を取得
        expect(actual_user.email).to eq(email)
        expect(actual_user.activated).to be_truthy
      end
    end
  end

  describe '#update_password' do
    context '正常系' do
      context 'user_idとcurrent_password, new_passwordを受け取った場合' do
        before do
          travel_to Time.zone.local(2023, 5, 10, 3, 0, 0)
        end
        let!(:current_password) { 'P@ssw0rd' }
        let!(:new_password) { 'H$lloW0rld' }
        let!(:user) { create(:user, password: current_password, activated: true) }

        it 'new_passwordに更新されること' do
          UserRepository.update_password(user.id, current_password, new_password)
          actual = User.find(user.id)
          expect(actual.authenticate(new_password)).to be_truthy
        end
      end
    end
    context '異常系' do
      context 'current_passwordがDBと不一致の場合' do
        before do
          travel_to Time.zone.local(2023, 5, 10, 3, 0, 0)
        end
        let!(:current_password) { 'P@ssw0rd' }
        let!(:dummy_password) { 'H$lloW0rld' }
        let!(:user) { create(:user, password: dummy_password, activated: true) }

        it 'SecurityErrorがraiseされること' do
          expect { UserRepository.update_password(user.id, current_password, 'hogehgoe') }
            .to raise_error(SecurityError)
        end
      end
    end
  end
end
