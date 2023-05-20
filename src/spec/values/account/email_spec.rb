#frozen_string_literal: true

require 'rails_helper'
require 'rspec-rails'

describe Email do
  describe '#from_string' do
    context '正常系' do
      context 'グローバルドメインが.comの場合' do
        let!(:value) { 'aaa@hogehoge.com' }

        it 'Emailオブジェクトとしてメールアドレスが返されること' do
          email = Email.from_string(:value)
          expect(email.value).eq (:value)
        end
      end
    end

    context '異常系' do

    end
  end
end
