# frozen_string_literal: true

class PromptRepository
  class << self
    # プロンプトを登録する
    def create(user_id, prompts = {})
      # ラジオボタンのvalueは各テーブルのidに対応
      category = Category.find(prompts[:category_id])
      generative_ai_model = GenerativeAiModel.find(prompts[:generative_ai_model_id])

      Prompt.create!(
        user_id:,
        category_id: category.id,
        about: prompts[:about],
        input_example: prompts[:input_example],
        output_example: prompts[:output_example],
        prompt: prompts[:prompt],
        generative_ai_model_id: generative_ai_model.id,
        uuid: prompts[:uuid]
      )
    end
  
    # プロンプトを更新する
    def update(user_id, uuid, prompts = {})
      updates = {}
      updates[:category_id] = Category.find(prompts[:category]).id if prompts.key?(:category)
      updates[:generative_ai_model_id] = GenerativeAiModel.find(prompts[:generative_ai_model]).id if prompts.key?(:generative_ai_model)
      # 残りのフィールドは直接更新します
      updates[:about] = prompts[:about] if prompts.key?(:about)
      updates[:input_example] = prompts[:input_example] if prompts.key?(:input_example)
      updates[:output_example] = prompts[:output_example] if prompts.key?(:output_example)
      updates[:prompt] = prompts[:prompt] if prompts.key?(:prompt)
      Prompt.where(user_id:, uuid:).update!(updates)
    end

    # プロンプトを取得する
    def prompt_only(uuid)
      Prompt.find_by(uuid:)
    end

    # 詳細ページ用にプロンプトを取得する
    def prompt_detail(uuid)
      Prompt.left_outer_joins(:likes, :bookmarks).where(uuid: uuid).group(:id)
        .select('prompts.*', 'COUNT(DISTINCT likes.id) AS likes_count', 'COUNT(DISTINCT bookmarks.id) AS bookmarks_count').first
    end
  end
end

class IncorrectPasswordError < StandardError; end
