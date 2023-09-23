# frozen_string_literal: true

class CategoryService
  include SessionModule

  def initialize(token = nil)
    freeze
  end

  # カテゴリーリスト取得
  def show
    CategoryRepository.fetch_all.map(&:name)
  end
end
