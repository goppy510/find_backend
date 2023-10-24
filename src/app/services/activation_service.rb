# frozen_string_literal: true

# ユーザーがアクティベーションメールのリンクをクリックしたらアカウントを有効化するためのもの
class ActivationService
  class << self
    def activate(token)
      raise ArgumentError, 'tokenがありません' unless token

      service = Activation::ActivationDomain.activate(token)
      service&.activate
    end
  end
end
