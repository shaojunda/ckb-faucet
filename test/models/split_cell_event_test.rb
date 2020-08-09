# frozen_string_literal: true

require "test_helper"

class SplitCellEventTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
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
