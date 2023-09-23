# frozen_string_literal: true

class BookmarkRepository
  class << self
    # プロンプトを登録する
    def create(user_id, prompt_id)
      Bookmark.create!(
        user_id:,
        prompt_id:
      )
    end

    def delete(user_id, prompt_id)
      Bookmark.find_by(user_id:, prompt_id:).destroy
    end

    # 特定プロンプトのいいね数を取得する
    def show_by_prompt_id(prompt_id)
      Bookmark.where(prompt_id:)
    end
  end
end

class IncorrectPasswordError < StandardError; end
