class SplitCellEvent < ApplicationRecord
end

# == Schema Information
#
# Table name: split_cell_events
#
#  id           :bigint           not null, primary key
#  block_hash   :string
#  block_number :decimal(30, )
#  status       :integer          default(0)
#  tx_hash      :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
