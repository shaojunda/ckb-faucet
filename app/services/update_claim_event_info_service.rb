# frozen_string_literal: true

class UpdateClaimEventInfoService
  def call
    api = SdkApi.instance
    values = []
    ClaimEvent.processing.each do |claim_event|
      tx_hash = claim_event.tx_hash
      transaction_with_status = api.get_transaction(tx_hash)
      next if transaction_with_status.blank?

      tx_status = transaction_with_status.tx_status.status
      claim_event_status = tx_status == "committed" ? "processed" : claim_event.status
      values << { id: claim_event.id, status: claim_event_status, tx_status: tx_status, created_at: claim_event.created_at, updated_at: Time.current }
    end

    ClaimEvent.upsert_all(values)
  end
end
