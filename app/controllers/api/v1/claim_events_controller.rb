# frozen_string_literal: true

class Api::V1::ClaimEventsController < ApplicationController
  def create
    @claim_event = ClaimEvent.new(claim_events_params)
    if @claim_event.save
    else
      handle_errors
    end
  end

  private
    def handle_errors
      errors = @claim_event.errors.map { |_, error| error }
      if "h24_quota".in? errors
        raise Api::V1::ApiError::ExceedsDailyQuotaLimitPerProductError
      elsif "h24_quota_per_request_type".in? errors
        raise Api::V1::ApiError::ExceedsDailyQuotaLimitPerTypeError
      elsif "h24_total_quota".in? errors
        raise Api::V1::ApiError::ExceedsDailyQuotaLimitError
      end
    end

    def claim_events_params
      JSON.parse(request.body.read).dig("data", "attributes").merge(product_id: @current_product.id,
                                                                    access_key_id: @current_product.access_key_id,
                                                                    signature: @signature, request_timestamp: @request_timestamp,
                                                                    created_at_unixtimestamp: Time.current.to_i)
    end
end
