# frozen_string_literal: true

class ClaimEventValidator < ActiveModel::Validator
  MAXIMUM_CLAIM_COUNT_PER_DAY = 500

  def validate(record)
    product = record.product
    total_claim_count_must_be_less_than_or_equal_to_the_quota_limit(record)
    claim_count_per_product_must_be_less_than_or_equal_to_the_quota_limit(record, product)
    claim_count_per_type_must_be_less_than_or_equal_to_the_quota_limit(record, product)
  end

  private
    def total_claim_count_must_be_less_than_or_equal_to_the_quota_limit(record)
      if ClaimEvent.where("created_at_unixtimestamp >= ?", 24.hours.ago.to_i).count >= MAXIMUM_CLAIM_COUNT_PER_DAY
        record.errors.add(:quota_config, "h24_total_quota")
      end
    end

    def claim_count_per_type_must_be_less_than_or_equal_to_the_quota_limit(record, product)
      quota_config = product.quota_config
      if product.claim_events.where(request_type: record.request_type).where("created_at_unixtimestamp >= ?", 24.hours.ago.to_i).count >= quota_config["h24_quota_per_request_type"]
        record.errors.add(:quota_config, "h24_quota_per_request_type")
      end
    end

    def claim_count_per_product_must_be_less_than_or_equal_to_the_quota_limit(record, product)
      quota_config = product.quota_config
      if product.claim_events.where("created_at_unixtimestamp >= ?", 24.hours.ago.to_i).count >= quota_config["h24_quota"]
        record.errors.add(:quota_config, "h24_quota")
      end
    end
end
