# frozen_string_literal: true

require 'rails_helper'
require 'rspec-rails'

describe Account::CompanyName do
  describe '#from_string' do
    context '正常系' do
      context '正しい名前：漢字を受け取った場合' do
        let!(:value) { '株式会社' }

        it 'CompanyNameオブジェクトとして名前が返されること' do
          company_name = Account::CompanyName.from_string(value)
          expect(company_name).to eq value
        end
      end

      context '正しい名前：ひらがなを受け取った場合' do
        let!(:value) { 'かぶしきがいしゃめいくりーど' }

        it 'CompanyNameオブジェクトとして名前が返されること' do
          company_name = Account::CompanyName.from_string(value)
          expect(company_name).to eq value
        end
      end

      context '正しい名前：カタカナを受け取った場合' do
        let!(:value) { 'メイクリード' }

        it 'CompanyNameオブジェクトとして名前が返されること' do
          company_name = Account::CompanyName.from_string(value)
          expect(company_name).to eq value
        end
      end

      context '正しい名前：英字を受け取った場合' do
        let!(:value) { 'makelead' }

        it 'CompanyNameオブジェクトとして名前が返されること' do
          company_name = Account::CompanyName.from_string(value)
          expect(company_name).to eq value
        end
      end
    end

    context '異常系' do
      context 'valueがnilの場合' do
        let!(:value) { nil }

        it 'ArgumentErrorが発生すること' do
          expect { Account::CompanyName.from_string(value) }.to raise_error(ArgumentError)
        end
      end

      context '101文字以上の場合' do
        let!(:value) { 'a' * 101 }

        it 'FormatErrorが発生すること' do
          expect { Account::CompanyName.from_string(value) }.to raise_error(FormatError)
        end
      end
    end
  end
end
