# frozen_string_literal: true

require 'rails_helper'
require 'rspec-rails'

describe PromptData::Title do
  describe '#from_string' do
    context '正常系' do
      context '正しいTitleを受け取った場合' do
        let!(:value) { 'titleです。' }

        it 'Titleオブジェクトとして名前が返されること' do
          sentence = PromptData::Title.from_string(value)
          expect(sentence).to eq value
        end
      end
    end

    context '異常系' do
      context 'valueがnilの場合' do
        let!(:value) { nil }

        it 'ArgumentErrorが発生すること' do
          expect { PromptData::Title.from_string(value) }.to raise_error(ArgumentError)
        end
      end

      context '256文字以上の場合' do
        let!(:value) { 'a' * 256 }

        it 'FormatErrorが発生すること' do
          expect { PromptData::Title.from_string(value) }.to raise_error(FormatError)
        end
      end
    end
  end
end
