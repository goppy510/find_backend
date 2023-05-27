class SessionService
  attr_reader :email, :password, :token

  def initialize(email: nil, password: nil, token: nil)
    # ログイン後の
    if email.blank? && password.blank? and token.present?
    end
    @email = Account::Email.from_string(email)
    @password = Accoount::Password.from_string(password)
  end

  def login
    activated_user = entity(self.email, self.password)

    # プロフィール未入力の場合はその旨をjsonで返す（フロント側で入力画面に飛ばすため）
    return unless profile_created?(activated_user)

    # api認証用のtokenを生成する
    auth = activated_user.token_generate

    # ハッシュ形式にして呼び出し元に返す
    res = {}
    res[:user] = {
      exp: auth.payload[:exp],
      user: activated_user.id
    }
    res[:auth] = {
      token_for_cookie(auth)
    }
    res
  end

  private

  def entity(email, password)
    activated_user ||= User.find_activated(self.email, self.password)
    raise UserNotFound, '有効なユーザーが見つかりませんでした' unless activated_user
    activated_user
  end

  # クッキーに保存するトークン
  def token_for_cookie(auth)
    {
      value: auth.token,
      expires: Time.at(auth.payload[:exp]),
      secure: Rails.env.production?,
      http_only: true
    }
  end

  # emailからアクティブなユーザーを返す
  def find_activated(email, password)
    user = User.find_by(email: email, activated: true)
    return user ? user&.authenticate(password) : false
  end

  # ユーザープロフィールが登録されている場合trueを返す
  def profile_created?(activated_user)
    Profile.exists?(user_id: activated_user.id)
  end
end

class UserNotFound < StandardError; end
class InvalidUserError < StandardError; end
