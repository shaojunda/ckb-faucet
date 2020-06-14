# frozen_string_literal: true

class Output < ApplicationRecord
  enum status: { dead: 0, live: 1, collected: 2 }
  belongs_to :split_cell_event
end

# == Schema Information
#
# Table name: outputs
#
#  id                  :bigint           not null, primary key
#  block_hash          :string
#  capacity            :decimal(, )
#  cell_index          :integer
#  cellbase            :boolean
#  data                :binary
#  lock_args           :string
#  lock_code_hash      :string
#  lock_hash           :string
#  lock_hash_type      :string
#  output_data_len     :integer
#  status              :integer          default("live")
#  tx_hash             :string
#  type_args           :string
#  type_code_hash      :string
#  type_hash           :string
#  type_hash_type      :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  split_cell_event_id :bigint
#
# Indexes
#
#  index_outputs_on_split_cell_event_id     (split_cell_event_id)
#  index_outputs_on_status                  (status) WHERE (status = 1)
#  index_outputs_on_tx_hash_and_cell_index  (tx_hash,cell_index) UNIQUE
#
