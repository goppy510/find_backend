# frozen_string_literal: true

class PromptService
  class << self
    include SessionModule
    include Prompts::PromptError
    include Permissions::PermissionError

    def index(token, page)
      raise ArgumentError, 'tokenがありません' if token.blank?
      raise ArgumentError, 'pageがありません' if page.blank?

      user_id = authenticate_user(token)[:user_id]
      has_admin = PermissionService.has_admin_role?(user_id)
      has_read_prompt = PermissionService.has_read_prompt_role?(user_id)
      raise Prompts::PromptError::Forbidden if !has_read_prompt && !has_admin

      # 管理者権限ならtrue, それ以外は対象ユーザーと自分自身の契約IDが一致しているならtrue
      is_own_user = has_admin ? true : own_user?(user_id, target_user_id)
      raise Permissions::PermissionError::Forbidden unless is_own_user

      return Prompts::PromptDomain.index_all(page) if has_admin

      contract_id = ContractRepository.show(user_id).id
      raise Prompts::PromptError::Forbidden if contract_id.blank?

      Prompts::PromptDomain.index(
        contract_id, page
      )
    end

    def create(token, prompts)
      raise ArgumentError, 'tokenがありません' if token.blank?
      raise ArgumentError, 'promptsがありません' if prompts.blank?

      user_id = authenticate_user(token)[:user_id]
      if !PermissionService.has_create_prompt_role?(user_id) && !PermissionService.has_admin_role?(user_id)
        raise Prompts::PromptError::Forbidden
      end

      contract_id = ContractRepository.show(user_id).id
      Prompts::PromptDomain.create(user_id, contract_id, prompts:)
    end

    def update(token, uuid, prompts)
      raise ArgumentError, 'tokenがありません' if token.blank?
      raise ArgumentError, 'uuidがありません' if uuid.blank?
      raise ArgumentError, 'promptsがありません' if prompts.blank?

      user_id = authenticate_user(token)[:user_id]
      if !PermissionService.has_update_prompt_role?(user_id) && !PermissionService.has_admin_role?(user_id)
        raise Prompts::PromptError::Forbidden
      end

      contract_id = ContractRepository.show(user_id).id
      raise Prompts::PromptError::Forbidden unless own_user?(user_id, contract_id)
      raise Prompts::PromptError::Forbidden unless own_prompt?(uuid, contract_id)

      Prompts::PromptDomain.update(user_id, uuid, prompts:)
    end

    def destroy(token, uuid)
      raise ArgumentError, 'tokenがありません' if token.blank?
      raise ArgumentError, 'uuidがありません' if uuid.blank?

      user_id = authenticate_user(token)[:user_id]
      if !PermissionService.has_destroy_prompt_role?(user_id) && !PermissionService.has_admin_role?(user_id)
        raise Prompts::PromptError::Forbidden
      end

      contract_id = ContractRepository.show(user_id).id
      raise Prompts::PromptError::Forbidden unless own_user?(user_id, contract_id)
      raise Prompts::PromptError::Forbidden unless own_prompt?(uuid, contract_id)

      Prompts::PromptDomain.destroy(user_id, uuid)
    end

    # プロンプト表示
    def show(token, uuid)
      raise ArgumentError, 'tokenがありません' if token.blank?
      raise ArgumentError, 'uuidがありません' if uuid.blank?

      user_id = authenticate_user(token)[:user_id]
      if !PermissionService.has_read_prompt_role?(user_id) && !PermissionService.has_admin_role?(user_id)
        raise Prompts::PromptError::Forbidden
      end

      contract_id = ContractRepository.show(user_id).id
      raise Prompts::PromptError::Forbidden unless own_user?(user_id, contract_id)
      raise Prompts::PromptError::Forbidden unless own_prompt?(uuid, contract_id)

      # promptデータを取得
      Prompts::PromptDomain.show(user_id, uuid)
    end

    # いいね
    def like(token, prompt_id)
      raise ArgumentError, 'tokenがありません' if token.blank?
      raise ArgumentError, 'prompt_idがありません' if prompt_id.blank?

      user_id = authenticate_user(token)[:user_id]
      if !PermissionService.has_read_prompt_role?(user_id) && !PermissionService.has_admin_role?(user_id)
        raise Prompts::PromptError::Forbidden
      end

      Prompts::PromptDomain.like(user_id, prompt_id)
    end

    # いいね解除
    def dislike(token, prompt_id)
      raise ArgumentError, 'tokenがありません' if token.blank?
      raise ArgumentError, 'prompt_idがありません' if prompt_id.blank?

      user_id = authenticate_user(token)[:user_id]
      if !PermissionService.has_read_prompt_role?(user_id) && !PermissionService.has_admin_role?(user_id)
        raise Prompts::PromptError::Forbidden
      end

      Prompts::PromptDomain.dislike(user_id, prompt_id)
    end

    # いいね数
    def like_count(token, prompt_id)
      raise ArgumentError, 'tokenがありません' if token.blank?
      raise ArgumentError, 'prompt_idがありません' if prompt_id.blank?

      user_id = authenticate_user(token)[:user_id]
      if !PermissionService.has_read_prompt_role?(user_id) && !PermissionService.has_admin_role?(user_id)
        raise Prompts::PromptError::Forbidden
      end

      Prompts::PromptDomain.like_count(user_id, prompt_id)
    end

    # ブックマーク
    def bookmark(token, prompt_id)
      raise ArgumentError, 'tokenがありません' if token.blank?
      raise ArgumentError, 'prompt_idがありません' if prompt_id.blank?

      user_id = authenticate_user(token)[:user_id]
      if !PermissionService.has_read_prompt_role?(user_id) && !PermissionService.has_admin_role?(user_id)
        raise Prompts::PromptError::Forbidden
      end

      Prompts::PromptDomain.bookmark(user_id, prompt_id)
    end

    # ブックマーク解除
    def disbookmark(token, prompt_id)
      raise ArgumentError, 'tokenがありません' if token.blank?
      raise ArgumentError, 'prompt_idがありません' if prompt_id.blank?

      user_id = authenticate_user(token)[:user_id]
      if !PermissionService.has_read_prompt_role?(user_id) && !PermissionService.has_admin_role?(user_id)
        raise Prompts::PromptError::Forbidden
      end

      Prompts::PromptDomain.disbookmark(user_id, prompt_id)
    end

    # いいね数
    def bookmark_count(token, prompt_id)
      raise ArgumentError, 'tokenがありません' if token.blank?
      raise ArgumentError, 'prompt_idがありません' if prompt_id.blank?

      user_id = authenticate_user(token)[:user_id]
      if !PermissionService.has_read_prompt_role?(user_id) && !PermissionService.has_admin_role?(user_id)
        raise Prompts::PromptError::Forbidden
      end

      Prompts::PromptDomain.bookmark_count(user_id, prompt_id)
    end

    private

    # 契約IDとユーザーが正しい紐づけかチェックする
    def own_user?(user_id, contract_id)
      ContractMembershipRepository.show(user_id,
                                        contract_id).present? || ContractRepository.show(user_id).id == contract_id
    end

    # uuidとcontract_idが正しい紐づけかチェックする
    def own_prompt?(uuid, contract_id)
      prompt = PromptRepository.show(uuid)
      return false if prompt.blank?

      prompt.contract_id == contract_id
    end
  end
end
