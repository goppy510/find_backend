# frozen_string_literal: true

class SignupService
  class << self
    include SessionModule

    def signup(token, signups)
      domain_map = {
        contract: Signup::ContractSignupDomain,
        user: Signup::UserSignupDomain
      }
    
      user_id = authenticate_user(token)[:user_id] if token.present?
      role = :user if user_id.blank?
      role = PermissionService.has_contract_role?(user_id) ? :contract : :user if user_id.present?
      domain_class = domain_map[role] || domain_map[:user] # デフォルトは UserSignupDomain
      domain_class.signup(signups)
    end
  end
end
