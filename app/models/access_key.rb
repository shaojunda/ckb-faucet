# frozen_string_literal: true

require_relative "../lib/core_extensions/secure_token_with_length"

class AccessKey < ApplicationRecord
  enum status: { inactive: 0, active: 1 }

  belongs_to :product

  has_secure_token_with_length :access_key_id
  has_secure_token_with_length :secret_access_key, length: 40
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
