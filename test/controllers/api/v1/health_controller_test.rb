# frozen_string_literal: true

require "test_helper"

class Api::V1::HealthControllerTest < ActionDispatch::IntegrationTest
  setup do
    Account.create
    Product.generate(name: "KFC", quota_config: { h24_quota: 10, h24_quota_per_request_type: 5 })
  end

  test "should return success" do
    get api_v1_health_index_url

    assert_equal 200, response.status
  end

  test "should return correct attributes" do
    get api_v1_health_index_url
    assert_equal %w[balance_state claim_per_product_state total_claim_state], json.dig("data", "attributes").keys.sort
  end
end
