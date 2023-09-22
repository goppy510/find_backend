# frozen_string_literal: true

require 'rails_helper'

describe Api::Prompts::CategoryController, type: :request do
  include SessionModule

  describe 'GET /api/prompts/categories' do
    context '正常系' do
      context 'カテゴリが正しく存在する場合' do
        before do
          get '/api/prompts/categories'
        end

        it 'status_code: okを返すこと' do
          expect(response).to have_http_status(:ok)
        end

        it 'カテゴリ名が返されること' do
          expect(JSON.parse(response.body)).to eq(CategoryRepository.fetch_all.map(&:name))
        end
      end
    end
  end
end
