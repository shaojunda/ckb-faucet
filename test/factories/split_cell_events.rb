# frozen_string_literal: true

FactoryBot.define do
  factory :split_cell_event do
    tx_hash { "MyString" }
    block_number { "9.99" }
    block_hash { "MyString" }
    status { 0 }
  end
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
