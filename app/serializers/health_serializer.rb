# frozen_string_literal: true

class HealthSerializer
  include FastJsonapi::ObjectSerializer
  attributes :balance_state, :total_claim_state, :claim_per_product_state
end
