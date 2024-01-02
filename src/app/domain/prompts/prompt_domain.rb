# frozen_string_literal: true

module Prompts
  class PromptDomain
    include SessionModule
    include Prompts::PromptError

    attr_reader :user_id,
                :prompt_id,
                :prompts

    # フロントからは数値としてのIDを受け取る
    def initialize(user_id: nil, contract_id: nil, prompt_id: nil, uuid: nil, page: 1, prompts: nil)
      hash_prompts = prompts[:prompts] if prompts.present?
      @user_id = user_id if user_id.present?
      @contract_id = contract_id if contract_id.present?
      @prompt_id = prompt_id if prompt_id.present? # いいね、ブックマーク用
      @uuid = uuid if uuid.present? # プロンプト表示用
      @page = page.to_i if page.present? # プロンプト一覧用
    
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

    # プロンプト一覧取得
    def index
      return unless @page.present?

      PromptRepository.index(@contract_id, page: @page).to_a
    end

    # プロンプト新規作成
    def create
      PromptRepository.create(@user_id, @contract_id, @prompts)
      @prompts[:uuid]
    end

    # プロンプト更新
    def update
      PromptRepository.update(@user_id, @uuid, @prompts)
    end

    # プロンプト削除
    def destroy
      PromptRepository.destroy(@uuid)
    end

    # プロンプト表示
    def show
      PromptRepository.prompt_detail(@uuid)
    end

    # いいね
    def like
      LikeRepository.create(@user_id, @prompt_id)
    end

    # いいね解除
    def dislike
      LikeRepository.destroy(@user_id, @prompt_id)
    end

    # いいね数
    def like_count
      LikeRepository.count(@user_id, @prompt_id)
    end

    # ブックマーク
    def bookmark
      BookmarkRepository.create(@user_id, @prompt_id)
    end

    # ブックマーク解除
    def disbookmark
      BookmarkRepository.destroy(@user_id, @prompt_id)
    end

    # ブックマーク数
    def bookmark_count
      BookmarkRepository.count(@user_id, @prompt_id)
    end

    private

    # プロンプトデータ作成時に背制しえする（主にフロントのURL用）
    def generate_uuid
      SecureRandom.uuid
    end

    class << self
      def index(contract_id, page)
        raise ArgumentError, 'contract_idがありません' if contract_id.blank?
        raise ArgumentError, 'pageがありません' if page.blank?

        domain = new(contract_id: contract_id, page: page)
        prompt_list = domain&.index
        total_count = prompt_list.count
        # promptデータを取得
        response = prompt_list.map do |prompt|
          {
            id: prompt[:id],
            prompt_uuid: prompt[:uuid],
            category: prompt[:category_name],
            generative_ai_model: prompt[:generative_ai_model_name],
            title: prompt[:title],
            input_example: prompt[:input_example],
            output_example: prompt[:output_example],
            prompt: prompt[:prompt],
            about: prompt[:about],
            likes_count: prompt[:likes_count],
            bookmarks_count: prompt[:bookmarks_count],
            updated_at: prompt[:updated_at].strftime('%Y-%m-%d %H:%M:%S')
          }
        end
        return { items: response, total_count: total_count }
      end

      def create(user_id, contract_id, prompts)
        raise ArgumentError, 'user_idがありません' if user_id.blank?
        raise ArgumentError, 'contract_idがありません' if contract_id.blank?
        raise ArgumentError, 'promptsがありません' if prompts.blank?

        domain = new(user_id: user_id, contract_id: contract_id, prompts:)
        domain&.create
      end

      def update(user_id, uuid, prompts)
        raise ArgumentError, 'user_idがありません' if user_id.blank?
        raise ArgumentError, 'uuidがありません' if uuid.blank?
        raise ArgumentError, 'promptsがありません' if prompts.blank?

        domain = new(user_id: user_id, uuid:, prompts:)
        domain&.update
      end

      def destroy(user_id, uuid)
        raise ArgumentError, 'user_idがありません' if user_id.blank?
        raise ArgumentError, 'uuidがありません' if uuid.blank?

        domain = new(user_id: user_id, uuid:)
        domain&.destroy
      end

      # プロンプト表示
      def show(user_id, uuid)
        raise ArgumentError, 'user_idがありません' if user_id.blank?
        raise ArgumentError, 'uuidがありません' if uuid.blank?

        # promptデータを取得
        res = new(user_id: user_id, uuid:)&.show
        {
          id: res[:id],
          prompt_uuid: res[:uuid],
          category: res[:category_name],
          about: res[:about],
          input_example: res[:input_example],
          output_example: res[:output_example],
          prompt: res[:prompt],
          generative_ai_model: res[:generative_ai_model_name],
          likes_count: res[:likes_count],
          bookmarks_count: res[:bookmarks_count],
          updated_at: res[:updated_at].strftime('%Y-%m-%d %H:%M:%S')
        }
      end

      # いいね
      def like(user_id, prompt_id)
        raise ArgumentError, 'user_idがありません' if user_id.blank?
        raise ArgumentError, 'prompt_idがありません' if prompt_id.blank?

        domain = new(user_id: user_id, prompt_id:)
        domain&.like
      end

      # いいね解除
      def dislike(user_id, prompt_id)
        raise ArgumentError, 'user_idがありません' if user_id.blank?
        raise ArgumentError, 'prompt_idがありません' if prompt_id.blank?

        domain = new(user_id: user_id, prompt_id:)
        domain&.dislike
      end

      # いいね数
      def like_count(user_id, prompt_id)
        raise ArgumentError, 'user_idがありません' if user_id.blank?
        raise ArgumentError, 'prompt_idがありません' if prompt_id.blank?

        domain = new(user_id: user_id, prompt_id:)
        domain&.like_count
      end

      # ブックマーク
      def bookmark(user_id, prompt_id)
        raise ArgumentError, 'user_idがありません' if user_id.blank?
        raise ArgumentError, 'prompt_idがありません' if prompt_id.blank?

        domain = new(user_id: user_id, prompt_id:)
        domain&.bookmark
      end

      # ブックマーク解除
      def disbookmark(user_id, prompt_id)
        raise ArgumentError, 'user_idがありません' if user_id.blank?
        raise ArgumentError, 'prompt_idがありません' if prompt_id.blank?

        domain = new(user_id: user_id, prompt_id:)
        domain&.disbookmark
      end

      # いいね数
      def bookmark_count(user_id, prompt_id)
        raise ArgumentError, 'user_idがありません' if user_id.blank?
        raise ArgumentError, 'prompt_idがありません' if prompt_id.blank?

        domain = new(user_id: user_id, prompt_id:)
        domain&.bookmark_count
      end
    end
  end
end
