# frozen_string_literal: true

class SendCapacityService
  def call
    api = SdkApi.instance
    official_account = Account.last
    ckb_wallet = Wallet.new(api: api, from_addresses: official_account.address_hash)
    CKB::Config.instance.set_api(Rails.application.credentials.CKB_NODE_URL)

    ClaimEvent.pending.find_in_batches(batch_size: 1500) do |claim_events|
      to_infos = claim_events.map do |claim_event|
        lock_script = CKB::Types::Script.new(code_hash: CKB::Config::SECP256K1_BLAKE160_SIGHASH_ALL_TYPE_HASH, args: claim_event.pk160, hash_type: "type")
        target_address = CKB::Address.new(lock_script, mode: api.mode).generate

        { "#{target_address}": {capacity: 145 * 10**8, type: SudtTypeScriptGenerator.new(claim_event.uuid), data: CKB::Utils.generate_sudt_amount(0) } }.stringify_keys
      end

      tx_generator = ckb_wallet.advance_generate(to_infos: to_infos)
      tx = ckb_wallet.advance_sign(tx_generator: tx_generator, contexts: Rails.application.credentials.OFFICIAL_WALLET_PRIVATE_KEY)
      tx_hash = api.send_transaction(tx)
      claim_events.update_all(tx_hash: tx_hash, status: "processing")
    end
  end
end
