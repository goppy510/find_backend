# frozen_string_literal: true

class PromptRepository
  class << self
    # プロンプト一覧を取得する
    def index(contract_id, page: 1, per_page: 6, category: nil, generative_ai_model: nil, keyword: nil)
      prompts = Prompt.left_outer_joins(:likes, :bookmarks, :category, :generative_ai_model, user: :profile)

      # カテゴリーで絞り込み
      prompts = prompts.where(egories: { name: category }) if category.present?
      # AIモデルで絞り込み
      prompts = prompts.where(generative_ai_models: { name: generative_ai_model }) if generative_ai_model.present?
      # キーワードで絞り込み
      prompts = prompts.where('prompts.title LIKE ? OR prompts.about LIKE ? OR prompts.input_example LIKE ? OR prompts.output_example LIKE ? OR prompts.prompt LIKE ?', "%#{keyword}%", "%#{keyword}%", "%#{keyword}%", "%#{keyword}%", "%#{keyword}%") if keyword.present?
      
      prompts = prompts.where(contract_id: contract_id, prompts: { deleted: false })

      prompts = prompts.group('prompts.id', 'categories.name', 'generative_ai_models.name')
        .select('prompts.*', 'categories.name AS category_name', 'generative_ai_models.name AS generative_ai_model_name', 'COUNT(DISTINCT likes.id) AS likes_count', 'COUNT(DISTINCT bookmarks.id) AS bookmarks_count')
        .order('prompts.created_at DESC')
        .offset((page - 1) * per_page)
        .limit(per_page)
    end

    # プロンプトを登録する
    def create(user_id, contract_id, prompts = {})
      # ラジオボタンのvalueは各テーブルのidに対応
      category = Category.find(prompts[:category_id])
      generative_ai_model = GenerativeAiModel.find(prompts[:generative_ai_model_id])

      Prompt.create!(
        user_id:,
        category_id: category.id,
        contract_id: contract_id,
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
    def update(uuid, prompts = {})
      updates = {}
      updates[:category_id] = Category.find(prompts[:category]).id if prompts.key?(:category)
      updates[:generative_ai_model_id] = GenerativeAiModel.find(prompts[:generative_ai_model]).id if prompts.key?(:generative_ai_model)
      # 残りのフィールドは直接更新します
      updates[:about] = prompts[:about] if prompts.key?(:about)
      updates[:input_example] = prompts[:input_example] if prompts.key?(:input_example)
      updates[:output_example] = prompts[:output_example] if prompts.key?(:output_example)
      updates[:prompt] = prompts[:prompt] if prompts.key?(:prompt)
      Prompt.where(uuid:, deleted: false).update!(updates)
    end

    # プロンプトを論理削除する
    def destroy(uuid)
      Prompt.where(uuid:, deleted: false).update!(deleted: true)
    end

    # プロンプトを取得する
    def show(uuid)
      Prompt.find_by(uuid:, deleted: false)
    end

    # 詳細ページ用にプロンプトを取得する
    def prompt_detail(uuid)
      Prompt.left_outer_joins(:likes, :bookmarks, :category, :generative_ai_model, user: :profile)
        .where(uuid:, deleted: false)
        .group('prompts.id', 'categories.name', 'generative_ai_models.name')
        .select('prompts.*', 'categories.name AS category_name', 'generative_ai_models.name AS generative_ai_model_name', 'COUNT(DISTINCT likes.id) AS likes_count', 'COUNT(DISTINCT bookmarks.id) AS bookmarks_count')
        .first
    end
  end
end
