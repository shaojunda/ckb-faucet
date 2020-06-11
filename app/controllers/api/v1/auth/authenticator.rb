# frozen_string_literal: true

module Api
  module V1
    module Auth
      class Authenticator
        def initialize(request, claim_event_params)
          @request = request
          @claim_event_params = claim_event_params
        end

        def authenticate!
          check_authorization_header!
        end

        private
          attr_reader :request, :claim_event_params

          def check_authorization_header!
            authorization = request.headers["authorization"]
            raise Api::V1::ApiError::MissingAuthorizationHeaderError if authorization.blank?

            algorithm = authorization.split(" ")[0]
            raise Api::V1::ApiError::AlgorithmFieldInvalidError if algorithm != "CKBFS1-HMAC-SHA256"
          end
      end
    end
  end
end
