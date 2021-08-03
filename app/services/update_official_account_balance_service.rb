# frozen_string_literal: true

class UpdateOfficialAccountBalanceService
  def call
    api = SdkApi.instance
    ckb_wallet = CKB::Wallet.from_hex(api, Rails.application.credentials.OFFICIAL_WALLET_PRIVATE_KEY, indexer_api: api.indexer_api)
    Account.last.update(balance: ckb_wallet.get_balance)

    Rails.logger.info "UpdateOfficialAccountBalanceService done"
  end
end
