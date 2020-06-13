FactoryBot.define do
  factory :account do
    address_hash { "" }
    balance { "9.99" }
  end
end

# == Schema Information
#
# Table name: accounts
#
#  id           :bigint           not null, primary key
#  address_hash :string
#  balance      :decimal(30, )    default(0)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
