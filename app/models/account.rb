# frozen_string_literal: true

class Account < ApplicationRecord
  def self.create_official_account(from_block_number: 0)
    api = SdkApi.instance
    ckb_wallet = CKB::Wallet.from_hex(api, Rails.application.credentials.OFFICIAL_WALLET_PRIVATE_KEY, mode: api.mode)
    api.index_lock_hash(ckb_wallet.lock_hash, index_from: from_block_number)
    sleep 5
    balance = api.get_capacity_by_lock_hash(ckb_wallet.lock_hash)
    account = Account.find_or_create_by(address_hash: ckb_wallet.address)
    account.update(balance: balance.capacity)
  end
end

# == Schema Information
#
# Table name: accounts
#
#  id           :bigint           not null, primary key
#  address_hash :string
#  balance      :decimal(30, )    default(0)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
