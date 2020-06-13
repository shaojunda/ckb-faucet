FactoryBot.define do
  factory :split_cell_event do
    tx_hash { "MyString" }
    block_number { "9.99" }
    block_hash { "MyString" }
    status { 0 }
  end
end
