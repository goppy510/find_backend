module Session

  def login
    email = Email.from_string(params[:email])
    password = Password.from_string(params[:password])

    activated_user = UserRepository.find_by_activated(email, password)

    # プロフィール未入力の場合はその旨をjsonで返す（フロント側で入力画面に飛ばすため）
    render_error(400, 'user', 'profile_incomplete') unless ProfileRepository.find_by_user_id(activated_user.id)

    # api認証用のtokenを生成する
    auth = activated_user.genrate_token(activated_user)

    # クッキーのtoken等を入れる
    cookies[token_access_key] = save_token_cookie

    # ハッシュ形式にして呼び出し元に返す
    res = {
      exp: auth.payload[:exp],
      user_id: activated_user.id
    }
    render json: { res }
  end

  # ログアウト
  def logout
    Auth::AuthenticatorService.new.delete_cookie
    head(:ok)
  end

  # トークンが有効ならUserオブジェクトを返す
  def authenticate_user
    res = Auth::AuthenticatorService.new.authenticate_user
    render json: { res }
  end

  private

  def genrate_token(user)
    Auth::AuthTokenService.new(payload: { sub: user.id })
  end

  # クッキーに保存するトークン
  def save_token_cookie(auth)
    {
      value: auth.token,
      expires: Time.at(auth.payload[:exp]),
      secure: Rails.env.production?,
      http_only: true
    }
  end
end
