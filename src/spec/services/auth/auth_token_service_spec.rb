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
        context 'liftimeが引数にない場合' do
          it '@lifetimeが2 weeksであること' do
            service = Auth::AuthTokenService.new
            lifetime = service.instance_variable_get(:@lifetime)
            expect(lifetime).to eq(2.weeks)
          end
        end

        context 'lifetimeが引数にある場合' do
          it '@lifetimeが受け取った引数の日時になっていること' do
            service = Auth::AuthTokenService.new(lifetime: 1.hour)
            lifetime = service.instance_variable_get(:@lifetime)
            expect(lifetime).to eq(1.hour)
          end
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

  describe '#find_available_user' do
    context '正常系' do
      before do
        travel_to Time.zone.local(2023, 05, 10, 3, 0, 0)
      end

      let!(:user1) { create(:user, activated: true) }
      let!(:user2) { create(:user, activated: true) }

      context 'usersにレコードがあり、かつ、tokenが有効な場合' do
        let!(:token) { Auth::AuthTokenService.new(payload: { sub: user1.id }).token }

        it 'user.idがsubのvalueと一致すること' do
          service = Auth::AuthTokenService.new(token: token)
          actual_user = service.find_available_user
          expect(actual_user.id).to eq user1.id
        end
      end

      context 'usersにレコードがあり、かつ、tokenが無効な場合' do
        let!(:token) { Auth::AuthTokenService.new(payload: { sub: user1.id, exp: Time.zone.local(2023, 04, 10, 3, 0, 0).to_i }).token }

        it 'JWT::ExpiredSignatureが発生すること' do
          expect { Auth::AuthTokenService.new(token: token)}.to raise_error(JWT::ExpiredSignature)
        end
      end
    end
  end

  describe '#find_not_available_user' do
    context '正常系' do
      before do
        travel_to Time.zone.local(2023, 05, 10, 3, 0, 0)
      end

      let!(:user1) { create(:user) }
      let!(:user2) { create(:user) }

      context 'usersにレコードがあり、かつ、未アクティベートな場合' do
        let!(:token) { Auth::AuthTokenService.new(payload: { sub: user1.id }).token }

        it 'user.idがsubのvalueと一致すること' do
          service = Auth::AuthTokenService.new(token: token)
          actual_user = service.find_not_available_user
          expect(actual_user.id).to eq user1.id
        end
      end
    end
  end

  describe '#lifetime_text' do
    context '正常系' do
      before do
        travel_to Time.zone.local(2023, 05, 10, 3, 0, 0)
      end

      context '正しくauthが生成できた場合' do
        it '2週間が返ってくること' do
          service = Auth::AuthTokenService.new
          lifetime = service.lifetime_text
          expect(lifetime).to eq '2週間'
        end
      end
    end
  end
end
