# frozen_string_literal: true

require 'rails_helper'
require 'rspec-rails'
require 'faker'

describe CategoryRepository do
  describe '#fetch_all' do
    context '正常系' do
      context 'カテゴリが正しく存在する場合' do
        it 'すべてのカテゴリが取得されること' do
          categories = CategoryRepository.fetch_all.map(&:name)

          expect(categories.size).to eq(11)
          expect(categories).to include('IT・情報通信業')
          expect(categories).to include('金融・保険業')
          expect(categories).to include('不動産業')
          expect(categories).to include('交通・運輸業')
          expect(categories).to include('医療・福祉')
          expect(categories).to include('教育・学習支援業')
          expect(categories).to include('旅行・宿泊・飲食業')
          expect(categories).to include('エンターテインメント・マスコミ')
          expect(categories).to include('広告・マーケティング')
          expect(categories).to include('コンサルティング業')
          expect(categories).to include('その他')
        end
      end
    end
  end
end
