# frozen_string_literal: true

class UpdateClaimEventInfoService
  def call
    api = SdkApi.instance
    values = []
    collected_output_values = { tx_hash: [], cell_index: [] }
    ClaimEvent.processing.each do |claim_event|
      tx_hash = claim_event.tx_hash
      transaction_with_status = api.get_transaction(tx_hash)
      next if transaction_with_status.blank?

      tx_status = transaction_with_status.tx_status.status
      tx = transaction_with_status.transaction
      tx.inputs.each do |input|
        tx_hash = input.previous_output.tx_hash
        index = input.previous_output.index
        collected_output_values[:tx_hash]<< tx_hash
        collected_output_values[:cell_index] << index
      end
      claim_event_status = tx_status == "committed" ? "processed" : claim_event.status
      values << { id: claim_event.id, status: claim_event_status, tx_status: tx_status, created_at: claim_event.created_at, updated_at: Time.current }
    end

    if values.present?
      ClaimEvent.upsert_all(values)
      Output.collected.where(collected_output_values).update_all(status: "dead")
    end

    Rails.logger.info "UpdateClaimEventInfoService done"
  end
end
