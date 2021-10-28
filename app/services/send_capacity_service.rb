# frozen_string_literal: true

class SendCapacityService
  def call
    api = SdkApi.instance
    official_account = Account.last
    ckb_wallet = Wallet.new(api: api, from_addresses: official_account.address_hash)
    process_old_acp_claim_events(api, ckb_wallet)
    process_new_acp_claim_events(api, ckb_wallet)

    Rails.logger.info "SendCapacityService done"
  end

  def process_old_acp_claim_events(api, ckb_wallet)
    ClaimEvent.pending.where(acp_type: "old").find_in_batches(batch_size: 1500) do |claim_events|
      ActiveRecord::Base.transaction do
        to_infos = claim_events.map do |claim_event|
          lock_script = CKB::Types::Script.new(code_hash: api.acp_code_hash, args: claim_event.pk160, hash_type: api.acp_hash_type)
          target_address = CKB::Address.new(lock_script, mode: api.mode).generate

          { "#{target_address}": { capacity: 145 * 10**8, type: SudtTypeScriptGenerator.new(claim_event.request_uuid).type_script, data: CKB::Utils.generate_sudt_amount(0) } }.stringify_keys
        end
        tx_generator = ckb_wallet.advance_generate(to_infos: to_infos)
        tx = ckb_wallet.advance_sign(tx_generator: tx_generator, contexts: Rails.application.credentials.OFFICIAL_WALLET_PRIVATE_KEY)
        tx_hash = api.send_transaction(tx, "passthrough")
        values = claim_events.map do |claim_event|
          { id: claim_event.id, tx_hash: tx_hash, status: "processing", created_at: claim_event.created_at, updated_at: Time.current }
        end
        ClaimEvent.upsert_all(values)
      end
    end
  end

  def process_new_acp_claim_events(api, ckb_wallet)
    api.acp_type = "new"
    ClaimEvent.pending.where(acp_type: "new").find_in_batches(batch_size: 1500) do |claim_events|
      ActiveRecord::Base.transaction do
        to_infos = claim_events.map do |claim_event|
          api.acp_type = claim_event.acp_type
          lock_script = CKB::Types::Script.new(code_hash: api.acp_code_hash, args: claim_event.pk160, hash_type: api.acp_hash_type)
          target_address = CKB::Address.new(lock_script, mode: api.mode).generate

          { "#{target_address}": { capacity: 145 * 10**8, type: SudtTypeScriptGenerator.new(claim_event.request_uuid).type_script, data: CKB::Utils.generate_sudt_amount(0) } }.stringify_keys
        end
        tx_generator = ckb_wallet.advance_generate(to_infos: to_infos)
        tx = ckb_wallet.advance_sign(tx_generator: tx_generator, contexts: Rails.application.credentials.OFFICIAL_WALLET_PRIVATE_KEY)
        tx_hash = api.send_transaction(tx, "passthrough")
        values = claim_events.map do |claim_event|
          { id: claim_event.id, tx_hash: tx_hash, status: "processing", created_at: claim_event.created_at, updated_at: Time.current }
        end
        ClaimEvent.upsert_all(values)
      end
    end
  end
end
