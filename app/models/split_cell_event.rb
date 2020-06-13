# frozen_string_literal: true

class SplitCellEvent < ApplicationRecord
  enum status: { pending: 0, completed: 1, forked: 2 }
  has_many :outputs
end

# == Schema Information
#
# Table name: split_cell_events
#
#  id           :bigint           not null, primary key
#  block_hash   :string
#  block_number :decimal(30, )
#  status       :integer          default("pending")
#  tx_hash      :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
