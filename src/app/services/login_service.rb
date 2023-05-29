class LoginService
  include SessionModule

  def initialize(email, password)
    @email = Account::Email.from_string(email)
    @password = Account::Password.from_string(password)
  end

  # ログイン
  def login
    activated_user = UserRepository.find_by_activated(@email, @password)
    return unless activated_user

    # プロフィール未入力の場合はその旨をjsonで返す（フロント側で入力画面に飛ばすため）
    return unless ProfileRepository.find_by_user_id(activated_user.id)

    # api認証用のtokenを生成する
    payload = api_payload(activated_user)
    auth = generate_token(payload: payload)

    res = {}
    res[:cookie] = save_token_cookie(auth)
    res[:response] = {
      exp: auth.payload[:exp],
      user_id: activated_user.id
    }
    res
  end
end
