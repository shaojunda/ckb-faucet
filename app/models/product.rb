# frozen_string_literal: true

class Product < ApplicationRecord
  enum status: { active: 0, inactive: 1 }
  VALID_QUOTA_CONFIG_KEYS = %w(h24_quota h24_quota_per_request_type)

  has_many :claim_events

  validate :quota_config_key_must_correct

  def self.generate(name:, quota_config:)
    ActiveRecord::Base.transaction do
      access_key = AccessKey.create!
      product = self.create!(name: name, quota_config: quota_config, access_key_id: access_key.access_key_id, secret_access_key: access_key.secret_access_key)
      access_key.update(product: product)
    end
  end

  private
    def quota_config_key_must_correct
      errors.add(:quota_config, "quota_config invalid") if quota_config.stringify_keys.keys != VALID_QUOTA_CONFIG_KEYS
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
#  status            :integer          default(0)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  access_key_id     :string
#
# Indexes
#
#  index_products_on_access_key_id_and_secret_access_key  (access_key_id,secret_access_key) UNIQUE
#  index_products_on_name                                 (name) UNIQUE
#
