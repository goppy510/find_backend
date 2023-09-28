# frozen_string_literal: true

require 'rails_helper'
require 'rspec-rails'

describe Account::Email do
  describe '#from_string' do
    context '正常系' do
      context 'ユーザー名部分がアルファベットのみの場合' do
        let!(:value) { 'aaa@hogehoge.com' }

        it 'Emailオブジェクトとしてメールアドレスが返されること' do
          email = Account::Email.from_string(value)
          expect(email).to eq value
        end
      end

      context 'ユーザー名にピリオドを含む場合' do
        let!(:value) { 'aaa.hoge@hogehoge.com' }

        it 'Emailオブジェクトとしてメールアドレスが返されること' do
          email = Account::Email.from_string(value)
          expect(email).to eq value
        end
      end

      context 'ユーザー名に「-」を含む場合' do
        let!(:value) { 'aaa-hoge@hogehoge.com' }

        it 'Emailオブジェクトとしてメールアドレスが返されること' do
          email = Account::Email.from_string(value)
          expect(email).to eq value
        end
      end

      context 'ユーザー名に「＿」を含む場合' do
        let!(:value) { 'aaa_hoge@hogehoge.com' }

        it 'Emailオブジェクトとしてメールアドレスが返されること' do
          email = Account::Email.from_string(value)
          expect(email).to eq value
        end
      end

      context 'ユーザー名に数値を含む場合' do
        let!(:value) { 'aaa5oge@hogehoge.com' }

        it 'Emailオブジェクトとしてメールアドレスが返されること' do
          email = Account::Email.from_string(value)
          expect(email).to eq value
        end
      end

      context 'サブドメインがある場合' do
        let!(:value) { 'aaa5oge@hogehoge.ac.jp' }

        it 'Emailオブジェクトとしてメールアドレスが返されること' do
          email = Account::Email.from_string(value)
          expect(email).to eq value
        end
      end

      context 'メールアドレスに大文字が含まれている場合' do
        let!(:actual_value) { 'aaA5oGe@hogehoge.ac.jp' }
        let!(:expect_value) { 'aaa5oge@hogehoge.ac.jp' }

        it '小文字として登録されること' do
          email = Account::Email.from_string(actual_value)
          expect(email).to eq expect_value
        end
      end
    end

    context '異常系' do
      context 'ドメインがない場合' do
        let!(:value) { 'invalid_email' }

        it 'EmailFormatErrorが発生すること' do
          expect { Account::Email.from_string(value) }.to raise_error(Account::Email::EmailFormatError)
        end
      end

      context 'トップレベルドメインがない場合' do
        let!(:value) { 'user@-' }

        it 'EmailFormatErrorが発生すること' do
          expect { Account::Email.from_string(value) }.to raise_error(Account::Email::EmailFormatError)
        end
      end

      context 'ユーザー名がない場合' do
        let!(:value) { '@example.com' }

        it 'EmailFormatErrorが発生すること' do
          expect { Account::Email.from_string(value) }.to raise_error(Account::Email::EmailFormatError)
        end
      end

      context 'ユーザー名においてピリオドが連続している場合' do
        let!(:value) { 'user..name@example.com' }

        it 'EmailFormatErrorが発生すること' do
          expect { Account::Email.from_string(value) }.to raise_error(Account::Email::EmailFormatError)
        end
      end

      context 'トップレベルドメインの一番後ろにピリオドがある場合' do
        let!(:value) { 'user@example.com.' }

        it 'EmailFormatErrorが発生すること' do
          expect { Account::Email.from_string(value) }.to raise_error(Account::Email::EmailFormatError)
        end
      end

      context '先頭にピリオドがある場合' do
        let!(:value) { '.user@example.com' }

        it 'EmailFormatErrorが発生すること' do
          expect { Account::Email.from_string(value) }.to raise_error(Account::Email::EmailFormatError)
        end
      end

      context '@マークの前後にピリオドがある場合' do
        let!(:values) do
          [
            'user.@example.com',
            'user@.example.com'
          ]
        end

        it 'EmailFormatErrorが発生すること' do
          values.each do |value|
            expect { Account::Email.from_string(value) }.to raise_error(Account::Email::EmailFormatError)
          end
        end
      end
    end
  end
end
