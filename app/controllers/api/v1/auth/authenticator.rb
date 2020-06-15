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
          check_product!
          check_ckbfs_date!
          check_body!
          check_timestamp!
          check_signature!

          return product, timestamp, signature
        end

        private
          attr_accessor :request, :claim_event_params, :timestamp

          def check_signature!
            SignatureValidator.new(request, timestamp, product.secret_access_key, signature).validate!
          end

          def check_timestamp!
            TimestampValidator.new(timestamp).validate!
          end

          def check_body!
            return if request.body.size.zero?

            BodyValidator.new(request.body).validate!
          end

          def check_ckbfs_date!
            raise Api::V1::ApiError::DateHeaderMissingError if request.headers["x-ckbfs-date"].blank?

            @timestamp = request.headers["x-ckbfs-date"]
          end

          def check_authorization_header!
            authorization = request.headers["authorization"]
            AuthorizationHeaderValidator.new(authorization).validate!
          end

          def check_product!
            raise Api::V1::ApiError::ProductNotFoundError if product.blank?
          end

          def product
            @product ||= Product.find_by(access_key_id: access_key_id, status: "active")
          end

          def signature
            @signature ||= begin
                             authorization = request.headers["authorization"]
                             target_key = "Signature="
                             credential_index = authorization.index(target_key) + target_key.size
                             authorization[credential_index..-1]
                           end
          end

          def access_key_id
            authorization = request.headers["authorization"]
            target_key = "Credential="
            credential_index = authorization.index(target_key) + target_key.size
            authorization[credential_index, 24]
          end
      end
    end
  end
end
