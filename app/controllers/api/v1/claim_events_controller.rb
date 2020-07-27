# frozen_string_literal: true

class Api::V1::ClaimEventsController < ApplicationController
  include Api::V1::Error::ErrorHandler

  def create
    @claim_event = ClaimEvent.new(claim_events_params)
    if @claim_event.save
      render json: ClaimEventSerializer.new(@claim_event)
    else
      handle_errors(@claim_event)
    end
  rescue ArgumentError
    raise Api::V1::ApiError::RequestTypeInvalidError
  end

  def show
    claim_event = ClaimEvent.find(params[:id])
    render json: ClaimEventSerializer.new(claim_event)
  rescue ActiveRecord::RecordNotFound
    raise Api::V1::ApiError::ClaimEventNotFoundError
  end

  private
    def claim_events_params
      JSON.parse(request.body.read).dig("data", "attributes").merge(product_id: @current_product.id,
                                                                    access_key_id: @current_product.access_key_id,
                                                                    signature: @signature, request_timestamp: @request_timestamp,
                                                                    created_at_unixtimestamp: Time.current.to_i)
    end
end
