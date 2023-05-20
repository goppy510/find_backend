#frozen_string_literal: true

require 'rails_helper'
require 'rspec-rails'

describe RegistrationToken do
  describe '#generate' do
    context '正常系' do
      it 'トークンが生成されること' do
        token = RegistrationToken.generate
        expect(token).not_to be_nil
        expect(token).to match(/\A[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}\z/i)
      end
    end
  end
end
