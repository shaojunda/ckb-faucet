# frozen_string_literal: true

module Api
  module V1
    module Auth
      class Authenticator
        def initialize(request)
          @request = request
        end

        def authenticate!
          check_authorization_header!
          check_ckbfs_date!
          check_body!
          check_timestamp!
        end

        private
          attr_accessor :request, :claim_event_params, :access_key_id

          def check_timestamp!
            tolerant_time = 5.minutes
            timestamp = request.headers["x-ckbfs-date"].in_time_zone("UTC").to_i
            raise Api::V1::ApiError::TimestampInvalidError if (Time.now.utc.to_i - timestamp).abs > tolerant_time
          end

          def check_body!
            request_body = JSON.parse(request.body.read)
            if request_body.keys.size != 1 || request_body.keys.first != "data" || request_body.dig("data").keys.sort != %w(attributes id type) ||
                request_body.dig("data", "type") != "claim_event" ||  request_body.dig("data", "attributes").keys.sort != %w(request_uuid request_type pk160).sort
              raise Api::V1::ApiError::RequestBodyInvalidError
            end
          rescue JSON::ParserError
            raise Api::V1::ApiError::RequestBodyInvalidError
          end

          def check_ckbfs_date!
            raise Api::V1::ApiError::DateHeaderMissingError if request.headers["x-ckbfs-date"].blank?
          end

          def check_authorization_header!
            authorization = request.headers["authorization"]
            raise Api::V1::ApiError::MissingAuthorizationHeaderError if authorization.blank?

            authorization_fields = authorization.split(" ")
            check_algorithm!(authorization_fields[0])
            check_credential!(authorization_fields[1])
            check_product!
            check_signed_headers!(authorization_fields[2])
            check_signature_format!(authorization_fields[3])
          end

          def check_product!
            raise Api::V1::ApiError::ProductNotFoundError if product.blank?
          end

          def check_algorithm!(algorithm)
            raise Api::V1::ApiError::AlgorithmFieldInvalidError if algorithm != "CKBFS1-HMAC-SHA256"
          end

          def check_credential!(credential)
            credential_values = credential&.split("=")
            raise Api::V1::ApiError::CredentialFieldInvalidError if credential.blank? || credential_values[0] != "Credential" || credential_values[1].blank?

            @access_key_id = credential_values[1].split("/")[0]
            raise Api::V1::ApiError::AccessKeyIdInvalidError if access_key_id.size != 24
          end

          def check_signed_headers!(signed_headers)
            signed_header_values = signed_headers&.split("=")
            raise Api::V1::ApiError::SignedHeadersInvalidError if signed_headers.blank? || signed_header_values[0] != "SignedHeaders" || signed_header_values[1].gsub(",", "") != %w(host x-ckbfs-date x-ckbfs-content-sha256).sort.join(";")
          end

          def check_signature_format!(signature)
            signature_values = signature&.split("=")
            raise Api::V1::ApiError::SignatureMissingError if signature.blank? || signature_values[0] != "Signature" || signature_values[1].blank?
          end

          def product
            @product ||= Product.find_by(access_key_id: access_key_id)
          end
      end
    end
  end
end
