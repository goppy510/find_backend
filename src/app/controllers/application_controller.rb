# frozen_string_literal: true

class ActionController::AuthenticationError < ActionController::ActionControllerError; end
class ActionController::UserNotFound < ActionController::ActionControllerError; end
class ActionController::Forbidden < ActionController::ActionControllerError; end
class ActionController::Unauthorized < ActionController::ActionControllerError; end
class ActionController::BadRequest < ActionController::ActionControllerError; end

class ApplicationController < ActionController::Base
  protect_from_forgery with: :null_session

  include SessionModule
  include ErrorHandlers

  # エラーをjsonで返すメソッド
  def render_error(status = 400, resource, code)
    message = I18n.t("errors.#{resource}.#{code}")
    render json: { error: { status: status, code: code,  message: message } }, status: status
  end
end
