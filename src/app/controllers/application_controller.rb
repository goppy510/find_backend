class ApplicationController < ActionController::Base
  before_action :authenticate_token

  extend T::Sig

  # エラーをjsonで返すメソッド
  sig { params(status: Integer, resource: String, code: String).void }
  def render_error(status = 400, resource, code)
    message = I18n.t("errors.#{resource}.#{code}")
    render json: { error: { status: status, code: code,  message: message }, status: status
  end

  private

  def authenticate_token
    # トークンのチェックを行うロジックを実装
    # トークンが無効な場合は適切な処理を行う（リダイレクト、エラーレスポンスなど）
  end
end
