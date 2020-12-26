# frozen_string_literal: true

FactoryBot.define do
  factory :claim_event do
    product
    access_key_id { SecureRandom.base58(24) }
    request_uuid { "0x#{SecureRandom.hex(21)}" }
    pk160 { "0x#{SecureRandom.hex(21)}" }
    signature { SecureRandom.hex(32) }
    request_type { 1 }
    request_timestamp { Time.now.utc.strftime("%Y%m%dT%H%M%SZ") }
    capacity { 145 * 10**8 }
    status { 0 }
    tx_hash { "0x#{SecureRandom.hex(32)}" }
    tx_status { 0 }
    created_at_unixtimestamp { Time.current.to_i }
    acp_type { "new" }
  end
end

# == Schema Information
#
# Table name: claim_events
#
#  id                       :uuid             not null, primary key
#  acp_type                 :integer          default("new")
#  capacity                 :decimal(, )
#  created_at_unixtimestamp :integer
#  pk160                    :string
#  request_timestamp        :string
#  request_type             :integer
#  request_uuid             :string
#  signature                :string
#  status                   :integer          default("pending")
#  tx_hash                  :string
#  tx_status                :integer          default("pending")
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  access_key_id            :string
#  product_id               :bigint
#
# Indexes
#
#  index_claim_events_on_created_at_unixtimestamp      (created_at_unixtimestamp)
#  index_claim_events_on_id_and_tx_hash_and_tx_status  (id,tx_hash,tx_status)
#  index_claim_events_on_product_id                    (product_id)
#
