# frozen_string_literal: true

class ClaimEvent < ApplicationRecord
  self.implicit_order_column = "created_at_unixtimestamp"

  DEFAULT_CAPACITY = 145 * 10**8
  MIN_ACP_ARGS_BYTESIZE = 20
  MAX_ACP_ARGS_BYTESIZE = 22

  enum status: { pending: 0, processing: 1, processed: 2, failed: 3 }
  enum tx_status: { pending: 0, proposed: 1, committed: 2, rejected: 3 }, _prefix: :tx
  enum request_type: { type0: 0, type1: 1 }
  enum acp_type: { old: 0, new: 1 }, _prefix: :acp_type

  belongs_to :product

  before_save :fill_default_capacity

  validates_with ClaimEventValidator, on: :create
  validate :valid_hex_string, on: :create

  private
    def fill_default_capacity
      self.capacity = DEFAULT_CAPACITY
    end

    def valid_hex_string
      unless CKB::Utils.valid_hex_string?(request_uuid)
        errors.add(:request_uuid, "request_uuid is not valid hex string")
      end
      if !CKB::Utils.valid_hex_string?(pk160)
        errors.add(:pk160, "pk160 is not valid hex string")
      else
        errors.add(:pk160, "invalid pk160") if pk160_invalid?
      end
    end

    def pk160_invalid?
      CKB::Utils.hex_to_bin(pk160).bytesize < MIN_ACP_ARGS_BYTESIZE || CKB::Utils.hex_to_bin(pk160).bytesize > MAX_ACP_ARGS_BYTESIZE
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
