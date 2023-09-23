# frozen_string_literal: true

class PromptService
  include SessionModule

  attr_reader :user_id,
              :prompt_id,
              :prompts

  # フロントからは数値としてのIDを受け取る
  def initialize(token, prompt_id: nil, prompts: nil)
    hash_prompts = prompts[:prompts] if prompts.present?
    @user_id = authenticate_user(token)[:user_id]
    @prompt_id = prompt_id if prompt_id.present? # いいね、ブックマーク用
  
    return if hash_prompts.blank?

    @prompts = {}
    @prompts[:uuid] = generate_uuid
    @prompts[:title] = PromptData::Title.from_string(hash_prompts[:title]) if hash_prompts&.key?(:title)
    @prompts[:about] = PromptData::About.from_string(hash_prompts[:about]) if hash_prompts&.key?(:about)
    if hash_prompts&.key?(:input_example)
      @prompts[:input_example] = PromptData::InputExample.from_string(hash_prompts[:input_example])
    end
    if hash_prompts&.key?(:output_example)
      @prompts[:output_example] = PromptData::OutputExample.from_string(hash_prompts[:output_example])
    end
    if hash_prompts&.key?(:prompt)
      @prompts[:prompt] = PromptData::Prompt.from_string(hash_prompts[:prompt])
    end
    # 以下、ラジオボタンの数値なのでバリデーションしない
    @prompts[:category_id] = hash_prompts[:category_id] if hash_prompts&.key?(:category_id)
    @prompts[:generative_ai_model_id] = hash_prompts[:generative_ai_model_id] if hash_prompts&.key?(:generative_ai_model_id)

    freeze
  end

  # プロンプト新規作成
  def create
    PromptRepository.create(@user_id, @prompts)
    @prompts[:uuid]
  end

  # プロンプト更新
  def update
    PromptRepository.update(@user_id, @prompt_id, @prompts)
  end

  # プロンプト削除
  def delete
    PromptRepository.delete(@user_id, @prompt_id)
  end

  # プロンプト表示
  def show
    PromptRepository.prompt_detail(@prompt_id)
  end

  # いいね
  def like
    LikeRepository.create(@user_id, @prompt_id)
  end

  # いいね解除
  def dislike
    LikeRepository.delete(@user_id, @prompt_id)
  end

  # ブックマーク
  def bookmark
    BookmarkRepository.create(@user_id, @prompt_id)
  end

  # ブックマーク解除
  def disbookmark
    BookmarkRepository.delete(@user_id, @prompt_id)
  end

  private

  # プロンプトデータ作成時に背制しえする（主にフロントのURL用）
  def generate_uuid
    SecureRandom.uuid
  end

  class << self
    def create(token, prompts)
      raise ArgumentError, 'tokenがありません' if token.blank?
      raise ArgumentError, 'promptsがありません' if prompts.blank?

      service = new(token, prompts:)
      service&.create
    end

    def update(token, prompt_id, prompts)
      raise ArgumentError, 'tokenがありません' if token.blank?
      raise ArgumentError, 'prompt_idがありません' if prompt_id.blank?
      raise ArgumentError, 'promptsがありません' if prompts.blank?

      service = new(token, prompt_id:, prompts:)
      service&.update
    end

    def delete(token, prompt_id)
      raise ArgumentError, 'tokenがありません' if token.blank?
      raise ArgumentError, 'prompt_idがありません' if prompt_id.blank?

      service = new(token, prompt_id:)
      service&.delete
    end

    # プロンプト表示
    def show(token, prompt_id)
      raise ArgumentError, 'tokenがありません' if token.blank?
      raise ArgumentError, 'prompt_idがありません' if prompt_id.blank?

      # promptデータを取得
      res = new(token, prompt_id:)&.show
      {
        id: res[:id],
        prompt_uuid: res[:uuid],
        category: res[:category_name],
        about: res[:about],
        input_example: res[:input_example],
        output_example: res[:output_example],
        prompt: res[:prompt],
        generative_ai_model: res[:generative_ai_model_name],
        nickname: res[:nickname],
        likes_count: res[:likes_count],
        bookmarks_count: res[:bookmarks_count],
      }
    end

    # いいね
    def like(token, prompt_id)
      raise ArgumentError, 'tokenがありません' if token.blank?
      raise ArgumentError, 'prompt_idがありません' if prompt_id.blank?

      service = new(token, prompt_id:)
      service&.like
    end

    # いいね解除
    def dislike(token, prompt_id)
      raise ArgumentError, 'tokenがありません' if token.blank?
      raise ArgumentError, 'prompt_idがありません' if prompt_id.blank?

      service = new(token, prompt_id:)
      service&.dislike
    end

    # ブックマーク
    # いいね
    def bookmark(token, prompt_id)
      raise ArgumentError, 'tokenがありません' if token.blank?
      raise ArgumentError, 'prompt_idがありません' if prompt_id.blank?

      service = new(token, prompt_id:)
      service&.bookmark
    end

    # いいね解除
    def disbookmark(token, prompt_id)
      raise ArgumentError, 'tokenがありません' if token.blank?
      raise ArgumentError, 'prompt_idがありません' if prompt_id.blank?

      service = new(token, prompt_id:)
      service&.disbookmark
    end
  end
end

class Unauthorized < StandardError; end
