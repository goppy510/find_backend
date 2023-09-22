# frozen_string_literal: true

require 'rails_helper'
require 'rspec-rails'

describe PromptData::ExampleInput do
  describe '#from_string' do
    context '正常系' do
      context '正しいExampleInputを受け取った場合' do
        let!(:value) { 'ExampleInputです。' }

        it 'ExampleInputオブジェクトとして名前が返されること' do
          sentence = PromptData::ExampleInput.from_string(value)
          expect(sentence).to eq value
        end
      end

      context '改行が入った文字を受け取る場合' do
        let!(:value) { 'ExampleInput\nです。' }

        it 'InputExampleオブジェクトとして名前が返されること' do
          sentence = PromptData::ExampleInput.from_string(value)
          expect(sentence).to eq value
        end
      end
    end

    context '異常系' do
      context 'valueがnilの場合' do
        let!(:value) { nil }

        it 'ArgumentErrorが発生すること' do
          expect { PromptData::ExampleInput.from_string(value) }.to raise_error(ArgumentError)
        end
      end

      context '4097文字以上の場合' do
        let!(:value) { 'a' * 4097 }

        it 'FormatErrorが発生すること' do
          expect { PromptData::ExampleInput.from_string(value) }.to raise_error(FormatError)
        end
      end
    end
  end
end
