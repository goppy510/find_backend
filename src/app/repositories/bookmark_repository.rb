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
    def count(user_id, prompt_id)
      bookmark_count = Bookmark.where(prompt_id: prompt_id).count
      is_bookmarked_by_user = Bookmark.exists?(user_id: user_id, prompt_id: prompt_id)
      
      { count: bookmark_count, is_bookmarked: is_bookmarked_by_user }
    end
  end
end

class IncorrectPasswordError < StandardError; end
