# frozen_string_literal: true

module Api
  module V1
    module Auth
      class BodyValidator
        attr_reader :request_body

        def initialize(request_body)
          @request_body = JSON.parse(request_body.read)
          request_body.rewind
        rescue JSON::ParserError
          raise Api::V1::ApiError::RequestBodyInvalidError
        end

        def validate!
          raise Api::V1::ApiError::RequestBodyInvalidError unless valid?
        end

        def valid_root_key?
          request_body.keys.size == 1 && request_body.keys.first == "data"
        end

        def valid_top_level_members?
          (request_body.dig("data").keys - %w(attributes id type)).blank?
        end

        def valid_resource_attributes?
          request_keys = request_body.dig("data", "attributes").keys.sort
          request_keys == %w(request_uuid request_type pk160).sort || request_keys == %w(request_uuid request_type pk160 acp_type).sort
        end

        def valid_resource_type?
          request_body.dig("data", "type") == "claim_event"
        end

        def valid?
          valid_root_key? &&
          valid_top_level_members? &&
          valid_resource_type? &&
          valid_resource_attributes?
        end
      end
    end
  end
end
