#frozen_string_literal: true

class ActivationService
  include SessionModule

  def initialize(token)
    @token = token
  end

  # activate
  def activate
    auth = authenticate_user_not_activate(@token) #SessionModuleのメソッド
    expires_at = Time.at(auth[:exp])
    raise ExpiredTokenError, 'tokenの有効期限が切れています' if expires_at < Time.current

    #アクティベートする
    user = UserRepository.find_by_id_not_activated(auth[:user_id])
    UserRepository.activate(user)
  end
end

class ExpiredTokenError < StandardError; end
