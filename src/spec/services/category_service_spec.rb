# frozen_string_literal: true

require 'rails_helper'
require 'rspec-rails'
require 'faker'

describe CategoryService do
  include SessionModule
  describe '#show' do
    context '正常系' do
      it 'カテゴリーリストを取得できること' do
        service = CategoryService.new
        expect(service.show).to eq(CategoryRepository.fetch_all.map(&:name))
      end
    end
  end
end
