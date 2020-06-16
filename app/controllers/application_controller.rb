# frozen_string_literal: true

class ApplicationController < ActionController::API
  before_action :check_header_info
  before_action :authenticate!
  rescue_from Api::V1::ApiError, with: :api_error

  private
    def check_header_info
      raise Api::V1::ApiError::ContentTypeInvalidError if content_type_invalid?
      raise Api::V1::ApiError::AcceptInvalidError if request.headers["Accept"] != "application/vnd.api+json"
    end

    def api_error(error)
      render json: ApiErrorSerializer.new([error], message: error.title), status: error.status
    end

    def content_type_invalid?
      content_type_invalid_for_update_action || content_type_invalid_for_fetch_action
    end

    def content_type_invalid_for_fetch_action
      !request.method.in?(%w[POST PUT]) && request.headers["Content-Type"].present? && request.headers["Content-Type"] != "application/vnd.api+json"
    end

    def content_type_invalid_for_update_action
      request.method.in?(%w[POST PUT]) && request.headers["Content-Type"] != "application/vnd.api+json"
    end

    def authenticate!
      @current_product, @request_timestamp, @signature = Api::V1::Auth::Authenticator.new(request).authenticate!
      end
end
