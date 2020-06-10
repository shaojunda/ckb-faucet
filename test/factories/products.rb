# frozen_string_literal: true

FactoryBot.define do
  factory :product do
    name { "KFC" }
    access_key_id { SecureRandom.base58(24) }
    secret_access_key { SecureRandom.base58(40) }
    quota_config { { "h24_quota": 100, "h24_quota_per_request_type": 50 } }
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
