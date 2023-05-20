#frozen_string_literal: true

require 'rails_helper'
require 'rspec-rails'

describe Registration do
  describe '#token' do
    context '正常系' do
      it 'トークンが生成されること' do
        token = Registration.token
        expect(token).not_to be_nil
        expect(token).to match(/\A[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}\z/i)
      end
    end
  end

  describe '#expires_at' do
    context '正常系' do
      before do
        travel_to Time.zone.local(2023, 05, 10, 3, 0, 0)
      end

      it '有効期限がが生成されること' do
        expires_at = Registration.expires_at
        expect(expires_at).to eq(Time.zone.local(2023, 05, 10, 4, 0, 0))
      end
    end
  end
end
