#frozen_string_literal: true

require 'rails_helper'
require 'rspec-rails'
require 'faker'

describe Auth::AuthTokenService do
  describe '#new' do
    context '正常系' do
      before do
        travel_to Time.zone.local(2023, 05, 10, 3, 0, 0)
      end

      context 'tokenが存在しない場合' do
        it '@lifetimeが2 weeksであること' do
          service = Auth::AuthTokenService.new
          lifetime = service.instance_variable_get(:@lifetime)
          expect(lifetime).to eq(2.weeks)
        end

        it '@payloadのaudがAPIホストであること,expが2023-05-24 03:00:00のタイムスタンプであること' do
          service = Auth::AuthTokenService.new
          payload = service.instance_variable_get(:@payload)
          expect(payload[:exp]).to eq(Time.parse('2023-05-24 03:00:00').to_i)
          expect(payload[:aud]).to eq(Settings[:app][:host])
        end

        it '@tokenが生成されていること' do
          service = Auth::AuthTokenService.new
          token = service.instance_variable_get(:@token)
          expect(token).not_to be_nil
        end
      end

      context 'tokenが存在する場合' do
        let!(:token) { Auth::AuthTokenService.new.token }

        it '@payloadのaudがAPIホストであること,expが2023-05-24 03:00:00のタイムスタンプであること' do
          service = Auth::AuthTokenService.new(token: token)
          payload = service.instance_variable_get(:@payload)
          expect(payload[:exp]).to eq(Time.parse('2023-05-24 03:00:00').to_i)
          expect(payload[:aud]).to eq(Settings[:app][:host])
        end

        it '@tokenが入力されたものと一致すること' do
          service = Auth::AuthTokenService.new(token: token)
          token = service.instance_variable_get(:@token)
          expect(token).not_to be_nil
        end
      end
    end
  end

  describe '#entity_for_user' do
    context '正常系' do
      before do
        travel_to Time.zone.local(2023, 05, 10, 3, 0, 0)
      end

      let!(:user1) { create(:user) }
      let!(:user2) { create(:user) }
      let!(:token) { user1.to_token }

      context 'usersにレコードがあり、かつ、tokenが有効な場合' do
        it 'user.idがsubのvalueと一致すること' do
          service = Auth::AuthTokenService.new(token: token)
          actual_user = service.entity_for_user
          expect(actual_user.id).to eq user1.id
        end
      end
    end

    context '異常系' do
      before do
        travel_to Time.zone.local(2023, 05, 10, 3, 0, 0)
      end

      context 'tokenがなかった場合' do
        it 'ArgumentErrorが発生すること' do
          expect{ ActivationService.new(nil) }.to raise_error(ArgumentError, 'tokenがありません')
        end
      end
    end
  end
end
