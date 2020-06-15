# frozen_string_literal: true

class ClaimEvent < ApplicationRecord
  self.implicit_order_column = "created_at_unixtimestamp"

  DEFAULT_CAPACITY = 145 * 10**8

  enum status: { pending: 0, processing: 1, processed: 2 }
  enum tx_status: { pending: 0, proposed: 1, committed: 2 }, _prefix: :tx
  enum request_type: { type0: 0, type1: 1 }

  belongs_to :product

  before_save :fill_default_capacity

  validates_with ClaimEventValidator, on: :create

  private
    def fill_default_capacity
      self.capacity = DEFAULT_CAPACITY
    end
end

# == Schema Information
#
# Table name: claim_events
#
#  id                       :uuid             not null, primary key
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
