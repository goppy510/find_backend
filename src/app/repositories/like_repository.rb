# frozen_string_literal: true

class LikeRepository
  class << self
    # プロンプトを登録する
    def create(user_id, prompt_id)
      Like.create!(
        user_id:,
        prompt_id:
      )
    end

    def destroy(user_id, prompt_id)
      Like.find_by(user_id:, prompt_id:).destroy
    end

    # 特定プロンプトのいいね数を取得する
    def count(user_id, prompt_id)
      like_count = Like.where(prompt_id: prompt_id).count
      is_liked_by_user = Like.exists?(user_id: user_id, prompt_id: prompt_id)
      
      { count: like_count, is_liked: is_liked_by_user }
    end
  end
end

class IncorrectPasswordError < StandardError; end
