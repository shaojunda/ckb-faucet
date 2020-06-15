# frozen_string_literal: true

require "test_helper"

class AccessKeyTest < ActiveSupport::TestCase
  test "should automatically generate secret_access_key when create access key" do
    product = create(:product)
    access_key = create(:access_key, product: product)

    assert_not_nil access_key.secret_access_key
    assert_equal 40, access_key.secret_access_key.size
  end

  test "should automatically generate access_key_id when create access key" do
    product = create(:product)
    access_key = create(:access_key, product: product)
    assert_not_nil access_key.access_key_id
    assert_equal 24, access_key.access_key_id.size
  end
end

# == Schema Information
#
# Table name: access_keys
#
#  id                :bigint           not null, primary key
#  secret_access_key :string           not null
#  status            :integer          default("active")
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  access_key_id     :string           not null
#  product_id        :bigint
#
# Indexes
#
#  index_access_keys_on_access_key_id      (access_key_id) UNIQUE
#  index_access_keys_on_product_id         (product_id)
#  index_access_keys_on_secret_access_key  (secret_access_key) UNIQUE
#
