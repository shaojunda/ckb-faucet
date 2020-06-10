# frozen_string_literal: true

require "test_helper"

class AccessKeyTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end

# == Schema Information
#
# Table name: access_keys
#
#  id                :bigint           not null, primary key
#  secret_access_key :string           not null
#  status            :integer          default(1)
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
