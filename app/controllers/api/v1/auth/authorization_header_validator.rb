# frozen_string_literal: true

module Api
  module V1
    module Auth
      class AuthorizationHeaderValidator
        def initialize(authorization)
          @authorization = authorization
          raise Api::V1::ApiError::MissingAuthorizationHeaderError if authorization.blank?

          authorization_fields = authorization.split(" ")
          @algorithm = authorization_fields[0]
          @credential = authorization_fields[1]
          @signed_headers = authorization_fields[2]
          @signature = authorization_fields[3]
        end

        def validate!
          check_algorithm!
          check_credential!
          check_signed_headers!
          check_signature_format!
        end

        private
          attr_reader :algorithm, :credential, :signed_headers, :signature, :access_key_id

          def check_algorithm!
            raise Api::V1::ApiError::AlgorithmFieldInvalidError if algorithm != "CKBFS1-HMAC-SHA256"
          end

          def check_credential!
            credential_values = credential&.split("=")
            raise Api::V1::ApiError::CredentialFieldInvalidError if credential.blank? || credential_values[0] != "Credential" || credential_values[1].blank?

            access_key_id = credential_values[1].split("/")[0]
            raise Api::V1::ApiError::AccessKeyIdInvalidError if access_key_id.size != 24

            service_name = credential_values[1].split("/")[2]
            raise Api::V1::ApiError::ServiceInvalidError if service_name != "faucet"
          end

          def check_signed_headers!
            signed_header_values = signed_headers&.split("=")
            raise Api::V1::ApiError::SignedHeadersInvalidError if signed_headers.blank? || signed_header_values[0] != "SignedHeaders" || signed_header_values[1].gsub(",", "") != %w(host x-ckbfs-date x-ckbfs-content-sha256).sort.join(";")
          end

          def check_signature_format!
            signature_values = signature&.split("=")
            raise Api::V1::ApiError::SignatureMissingError if signature.blank? || signature_values[0] != "Signature" || signature_values[1].blank?
          end
      end
    end
  end
end
