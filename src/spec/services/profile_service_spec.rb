# frozen_string_literal: true

require 'rails_helper'
require 'rspec-rails'
require 'faker'

describe ProfileService do
  include SessionModule

  before do
    travel_to Time.zone.local(2023, 5, 10, 3, 0, 0)
    allow(Profiles::ProfileDomain).to receive(:create)
    allow(Profiles::ProfileDomain).to receive(:update)
    allow(Profiles::ProfileDomain).to receive(:show)
  end

  describe '#self.create' do
    let!(:user) { create(:user, activated: true) }
    let!(:payload) do
      {
        sub: user.id,
        type: 'api'
      }
    end
    let!(:auth) { generate_token(payload:) }
    let!(:token) { auth.token }
    let!(:profiles) do
      {
        profiles: {
          name: '田中 太郎',
          phone_number: '08012345678',
          company_name: '株式会社makelead',
          employee_count: 1,
          industry: 2,
          position: 3,
          business_model: 2
        }
      }
    end

    context '正常系' do
      context 'tokenが有効な場合' do
        it 'Profiles::ProfileDomain.createが呼ばれること' do
          ProfileService.create(token, profiles)
          expect(Profiles::ProfileDomain).to have_received(:create)
        end
      end
    end

    context '異常系' do
      context 'tokenが無効な場合' do
        it '例外が発生すること' do
          expect { ProfileService.create('invalid_token', profiles) }.to raise_error(StandardError)
        end
      end
    end
  end

  describe '#self.update' do
    let!(:user) { create(:user, activated: true) }
    let!(:payload) do
      {
        sub: user.id,
        type: 'api'
      }
    end
    let!(:auth) { generate_token(payload:) }
    let!(:token) { auth.token }
    let!(:profiles) do
      {
        profiles: {
          name: '田中 太郎',
          phone_number: '08012345678',
          company_name: '株式会社makelead',
          employee_count: 1,
          industry: 2,
          position: 3,
          business_model: 2
        }
      }
    end

    context '正常系' do
      context 'tokenが有効な場合' do
        it 'Profiles::ProfileDomain.updateが呼ばれること' do
          ProfileService.update(token, profiles)
          expect(Profiles::ProfileDomain).to have_received(:update)
        end
      end
    end

    context '異常系' do
      context 'tokenが無効な場合' do
        it '例外が発生すること' do
          expect { ProfileService.update('invalid_token', profiles) }.to raise_error(StandardError)
        end
      end
    end
  end

  describe '#self.show' do
    let!(:user) { create(:user, activated: true) }
    let!(:payload) do
      {
        sub: user.id,
        type: 'api'
      }
    end
    let!(:auth) { generate_token(payload:) }
    let!(:token) { auth.token }

    context '正常系' do
      context 'tokenが有効な場合' do
        it 'Profiles::ProfileDomain.showが呼ばれること' do
          ProfileService.show(token)
          expect(Profiles::ProfileDomain).to have_received(:show)
        end
      end
    end

    context '異常系' do
      context 'tokenが無効な場合' do
        it '例外が発生すること' do
          expect { ProfileService.show('invalid_token') }.to raise_error(StandardError)
        end
      end
    end
  end
end
