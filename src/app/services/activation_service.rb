# frozen_string_literal: true

# ユーザーがアクティベーションメールのリンクをクリックしたらアカウントを有効化するためのもの
class ActivationService
  class << self
    def activate(token)
      raise ArgumentError, 'tokenがありません' unless token

      Activation::ActivationDomain&.activate(token)
    end
  end
end
