# frozen_string_literal: true

class ApplicationController < ActionController::API
  before_action :check_header_info
  before_action :authenticate!
  rescue_from Api::V1::ApiError, with: :api_error

  private
    def check_header_info
      raise Api::V1::ApiError::ContentTypeInvalidError if request.headers["Content-Type"] != "application/vnd.api+json"
      raise Api::V1::ApiError::AcceptInvalidError if request.headers["Accept"] != "application/vnd.api+json"
    end

    def api_error(error)
      render json: ApiErrorSerializer.new([error], message: error.title), status: error.status
    end

    def authenticate!
      @current_product, @request_timestamp, @signature = Api::V1::Auth::Authenticator.new(request).authenticate!
    end
end
