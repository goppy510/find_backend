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

    def delete(user_id, prompt_id)
      Like.find_by(user_id:, prompt_id:).destroy
    end

    # 特定プロンプトのいいね数を取得する
    def show_by_prompt_id(prompt_id)
      Like.where(prompt_id:)
    end
  end
end

class IncorrectPasswordError < StandardError; end
