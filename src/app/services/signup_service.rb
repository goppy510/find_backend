# frozen_string_literal: true

class SignupService
  class << self
    include SessionModule
    include Signup::SignupError

    def signup(token, signups)
      domain_map = {
        contract: Signup::ContractSignupDomain,
        user: Signup::UserSignupDomain
      }
    
      user_id = authenticate_user(token)[:user_id] if token.present?
      role = :user if user_id.present? && PermissionService.has_user_role?(user_id)
      role = :contract if user_id.present? && PermissionService.has_contract_role?(user_id)
      raise Signup::SignupError::Forbidden if role.blank?
      domain_class = domain_map[role]
      signups[:signups][:user_id] = user_id if role == :user
      domain_class.signup(signups)
    end
  end
end
