# frozen_string_literal: true

class Product < ApplicationRecord
  enum status: { active: 0, inactive: 1 }
  VALID_QUOTA_CONFIG_KEYS = %w(h24_quota h24_quota_per_request_type)

  has_many :claim_events
  has_many :access_keys, dependent: :delete_all

  validate :quota_config_key_must_correct

  def self.generate(name:, quota_config:)
    ActiveRecord::Base.transaction do
      product = self.create!(name: name, quota_config: quota_config)
      access_key = AccessKey.create!(product: product)
      product.update(access_key_id: access_key.access_key_id, secret_access_key: access_key.secret_access_key)

      product
    end
  end

  def secret_access_key=(value)
    super(EncryptionService.encrypt(value))
  end

  def secret_access_key
    EncryptionService.decrypt(super)
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
#  status            :integer          default("active")
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  access_key_id     :string
#
# Indexes
#
#  index_products_on_access_key_id_and_secret_access_key  (access_key_id,secret_access_key) UNIQUE
#  index_products_on_name                                 (name) UNIQUE
#
