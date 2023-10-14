# frozen_string_literal: true

require 'rails_helper'
require 'rspec-rails'

describe Account::Password do
  describe '#from_string' do
    context '正常系' do
      context 'パスワードの仕様を満たす場合' do
        let!(:value) { 'P@ssw0rd' }

        it 'Passwordオブジェクトとしてパスワードが返されること' do
          password = Account::Password.from_string(value)
          expect(password).to eq value
        end
      end
    end

    context '異常系' do
      context 'アルファベットだけの場合' do
        let!(:values) do
          %w[
            ssssssss
            SSSSSSSS
            sSsSsSsS
            SsSsSsS
          ]
        end

        it 'PasswordFormatErrorが発生すること' do
          values.each do |value|
            expect { Account::Password.from_string(value) }.to raise_error(Account::Password::PasswordFormatError)
          end
        end
      end

      context '数値だけの場合' do
        let!(:value) { 123_456_789 }

        it 'PasswordFormatErrorが発生すること' do
          expect { Account::Password.from_string(value) }.to raise_error(Account::Password::PasswordFormatError)
        end
      end

      context '数値とアルファベットだけの場合' do
        let!(:value) { '1234a567B89' }

        it 'PasswordFormatErrorが発生すること' do
          expect { Account::Password.from_string(value) }.to raise_error(Account::Password::PasswordFormatError)
        end
      end

      context '規定文字数未満の場合' do
        let!(:value) { 'aaaaaaa' }

        it 'PasswordFormatErrorが発生すること' do
          expect { Account::Password.from_string(value) }.to raise_error(Account::Password::PasswordFormatError)
        end
      end

      context '規定文字数超過の場合' do
        let!(:value) { 'a' * 51 }

        it 'PasswordFormatErrorが発生すること' do
          expect { Account::Password.from_string(value) }.to raise_error(Account::Password::PasswordFormatError)
        end
      end
    end
  end
end
