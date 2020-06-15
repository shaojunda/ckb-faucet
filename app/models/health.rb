# frozen_string_literal: true

class Health
  WEEKLY_MINIMUM_QUOTA = (200 * 7) * 145 * 10**8

  def id
    Time.current.to_i
  end

  def balance_state
    # 0 means normal 1 means abnormal
    account = Account.last
    account_balance = account.balance
    state = balance_less_than_the_amount_required_weekly?(account_balance) ? 1 : 0
    message = state == 1 ? "Alert! The current balance is #{account_balance}, which is lower than the weekly minimum quota ": ""

    { state: state, message: message }
  end

  def total_claim_state
    state = total_claim_count_greater_than_or_equal_to_the_quota_limit? ? 1 : 0
    message = state == 1 ? "Alert! The total claim count exceeds the maximum quota per day" : ""

    { state: state, message: message }
  end

  def claim_per_product_state
    product_name = claim_count_per_product_greater_than_or_equal_to_the_quota_limit_names
    state = product_name.present? ? 1 : 0
    message = state == 1 ? "Alert! Product #{product_name.join(", ")} exceeds the maximum quota per day" : ""

    { state: state, message: message }
  end

  private
    def balance_less_than_the_amount_required_weekly?(account_balance)
      account_balance < WEEKLY_MINIMUM_QUOTA
    end

    def total_claim_count_greater_than_or_equal_to_the_quota_limit?
      ClaimEvent.where("created_at_unixtimestamp >= ?", 24.hours.ago.to_i).count >= ClaimEventValidator::MAXIMUM_CLAIM_COUNT_PER_DAY
    end

    def claim_count_per_product_greater_than_or_equal_to_the_quota_limit_names
      Product.all.map do |product|
        quota_config = product.quota_config
        if product.claim_events.where(request_type: record.request_type).where("created_at_unixtimestamp >= ?", 24.hours.ago.to_i).count >= quota_config["h24_quota_per_request_type"]
          [product.name]
        end
      end.compact
    end
end
