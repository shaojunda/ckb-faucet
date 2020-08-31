# frozen_string_literal: true

FactoryBot.define do
  factory :output do
    split_cell_event_id { "" }
    block_hash { "MyString" }
    capacity { "9.99" }
    cell_index { 1 }
    data { "" }
    lock_args { "MyString" }
    lock_code_hash { "MyString" }
    lock_hash { "MyString" }
    lock_hash_type { "MyString" }
    output_data_len { 1 }
    status { 1 }
    tx_hash { "MyString" }
    type_args { "MyString" }
    type_code_hash { "MyString" }
    type_hash { "MyString" }
    type_hash_type { "MyString" }
  end
end

# == Schema Information
#
# Table name: outputs
#
#  id                  :bigint           not null, primary key
#  block_hash          :string
#  block_number        :decimal(, )
#  capacity            :decimal(, )
#  cell_index          :integer
#  cellbase            :boolean
#  checked             :boolean          default(FALSE)
#  data                :binary
#  lock_args           :string
#  lock_code_hash      :string
#  lock_hash           :string
#  lock_hash_type      :string
#  output_data_len     :integer
#  purpose             :integer          default("normal")
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
