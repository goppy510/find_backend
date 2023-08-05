# frozen_string_literal: true

require 'rails_helper'
require 'rspec-rails'

describe Account::Name do
  describe '#from_string' do
    context '正常系' do
      context '正しい名前：漢字を受け取った場合' do
        let!(:value) { '田中 太郎' }

        it 'Nameオブジェクトとして名前が返されること' do
          name = Account::Name.from_string(value)
          expect(name).to eq value
        end
      end

      context '正しい名前：ひらがなを受け取った場合' do
        let!(:value) { 'たなか たろう' }

        it 'Nameオブジェクトとして名前が返されること' do
          name = Account::Name.from_string(value)
          expect(name).to eq value
        end
      end

      context '正しい名前：カタカナを受け取った場合' do
        let!(:value) { 'タナカ タロウ' }

        it 'Nameオブジェクトとして名前が返されること' do
          name = Account::Name.from_string(value)
          expect(name).to eq value
        end
      end

      context '正しい名前：英字を受け取った場合' do
        let!(:value) { 'Tanaka Taro' }

        it 'Nameオブジェクトとして名前が返されること' do
          name = Account::Name.from_string(value)
          expect(name).to eq value
        end
      end
    end

    context '異常系' do
      context 'valueがnilの場合' do
        let!(:value) { nil }

        it 'ArgumentErrorが発生すること' do
          expect { Account::Name.from_string(value) }.to raise_error(ArgumentError)
        end
      end

      context '51文字以上の場合' do
        let!(:value) { 'a' * 51 }

        it 'FormatErrorが発生すること' do
          expect { Account::Name.from_string(value) }.to raise_error(FormatError)
        end
      end
    end
  end
end
