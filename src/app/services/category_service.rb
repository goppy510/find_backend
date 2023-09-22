# frozen_string_literal: true

class CategoryService
  include SessionModule

  attr_reader :email, :password, :token, :expires_at

  def initialize(token = nil)
    @user_id = authenticate_user(token)[:user_id] if token.present?
    freeze
  end

  # カテゴリーリスト取得
  def show
    CategoryRepository.fetch_all.map(&:name)
  end
end
