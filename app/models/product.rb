# frozen_string_literal: true

class Product < ApplicationRecord

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
