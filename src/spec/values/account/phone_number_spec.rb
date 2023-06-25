# frozen_string_literal: true

require 'rails_helper'
require 'rspec-rails'

describe Account::PhoneNumber do
  describe '#from_string' do
    context '正常系' do
      context '携帯番号の形式で受け取った場合' do
        let!(:value) { '09012345678' }

        it 'PhoneNumberオブジェクトとして番号が返されること' do
          name = Account::PhoneNumber.from_string(value)
          expect(name).to eq value
        end
      end

      context '会社の形式で受け取った場合' do
        let!(:value) { '0312345678' }

        it 'PhoneNumberオブジェクトとして番号が返されること' do
          name = Account::PhoneNumber.from_string(value)
          expect(name).to eq value
        end
      end
    end

    context '異常系' do
      context 'valueがnilの場合' do
        let!(:value) { nil }

        it 'ArgumentErrorが発生すること' do
          expect { Account::PhoneNumber.from_string(value) }.to raise_error(ArgumentError)
        end
      end

      context '0から始まらない番号の場合' do
        let!(:value) { '1312345678' }

        it 'FormatErrorが発生すること' do
          expect { Account::PhoneNumber.from_string(value) }.to raise_error(FormatError)
        end
      end

      context '文字数が多い場合' do
        let!(:value) { '0801234567891011121314' }

        it 'FormatErrorが発生すること' do
          expect { Account::PhoneNumber.from_string(value) }.to raise_error(FormatError)
        end
      end

      context '文字数が少ない場合' do
        let!(:value) { '03' }

        it 'FormatErrorが発生すること' do
          expect { Account::PhoneNumber.from_string(value) }.to raise_error(FormatError)
        end
      end

      context '数字以外の文字：英字が混入している場合' do
        let!(:value) { '0312345a678' }

        it 'FormatErrorが発生すること' do
          expect { Account::PhoneNumber.from_string(value) }.to raise_error(FormatError)
        end
      end

      context '数字以外の文字：記号が混入している場合' do
        let!(:value) { '080-12345-5678' }

        it 'FormatErrorが発生すること' do
          expect { Account::PhoneNumber.from_string(value) }.to raise_error(FormatError)
        end
      end
    end
  end
end
