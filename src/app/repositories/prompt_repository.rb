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
        title: prompts[:title],
        about: prompts[:about],
        input_example: prompts[:input_example],
        output_example: prompts[:output_example],
        prompt: prompts[:prompt],
        generative_ai_model_id: generative_ai_model.id,
        uuid: prompts[:uuid]
      )
    end
  
    # プロンプトを更新する
    def update(user_id, prompt_id, prompts = {})
      updates = {}
      updates[:category_id] = Category.find(prompts[:category]).id if prompts.key?(:category)
      updates[:generative_ai_model_id] = GenerativeAiModel.find(prompts[:generative_ai_model]).id if prompts.key?(:generative_ai_model)
      # 残りのフィールドは直接更新します
      updates[:about] = prompts[:about] if prompts.key?(:about)
      updates[:input_example] = prompts[:input_example] if prompts.key?(:input_example)
      updates[:output_example] = prompts[:output_example] if prompts.key?(:output_example)
      updates[:prompt] = prompts[:prompt] if prompts.key?(:prompt)
      Prompt.where(id: prompt_id, user_id:).update!(updates)
    end

    # プロンプトを論理削除する
    def delete(user_id, prompt_id)
      Prompt.where(id: prompt_id, user_id:).update!(deleted: true)
    end

    # プロンプトを取得する
    def prompt_only(prompt_id)
      Prompt.find_by(id: prompt_id, deleted: false)
    end

    # 詳細ページ用にプロンプトを取得する
    def prompt_detail(prompt_id)
      Prompt.left_outer_joins(:likes, :bookmarks, :category, :generative_ai_model, user: :profile)
        .where(id: prompt_id, deleted: false)
        .group('prompts.id', 'profiles.nickname', 'categories.name', 'generative_ai_models.name')
        .select('prompts.*', 'profiles.nickname AS nickname', 'categories.name AS category_name', 'generative_ai_models.name AS generative_ai_model_name', 'COUNT(DISTINCT likes.id) AS likes_count', 'COUNT(DISTINCT bookmarks.id) AS bookmarks_count')
        .first
    end
  end
end

class IncorrectPasswordError < StandardError; end
