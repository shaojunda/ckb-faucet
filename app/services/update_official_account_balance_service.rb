# frozen_string_literal: true

class UpdateOfficialAccountBalanceService
  def call
    api = SdkApi.instance
    ckb_wallet = CKB::Wallet.from_hex(api, Rails.application.credentials.OFFICIAL_WALLET_PRIVATE_KEY)
    balance = api.get_capacity_by_lock_hash(ckb_wallet.lock_hash)
    Account.last.update(balance: balance.capacity)

    Rails.logger.info "UpdateOfficialAccountBalanceService done"
  end
end
