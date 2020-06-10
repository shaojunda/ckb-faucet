# frozen_string_literal: true

require "test_helper"

class ProductTest < ActiveSupport::TestCase
  test ".generate should create a new Access Key" do
    assert_difference -> { AccessKey.count }, 1 do
      Product.generate(name: "KFC", quota_config: {})
    end
  end

  test ".generate should create a product" do
    assert_difference -> { Product.count }, 1 do
      Product.generate(name: "KFC", quota_config: {})
    end
  end

  test ".generate should create a product with access key tokens" do
    product = Product.generate(name: "KFC", quota_config: {})
    access_key = AccessKey.first

    assert_equal access_key.secret_access_key, product.secret_access_key
    assert_equal access_key.access_key_id, product.access_key_id
  end
end

# == Schema Information
#
# Table name: products
#
#  id                :bigint           not null, primary key
#  name              :string
#  quota_config      :jsonb
#  secret_access_key :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  access_key_id     :string
#
# Indexes
#
#  index_products_on_access_key_id_and_secret_access_key  (access_key_id,secret_access_key) UNIQUE
#
