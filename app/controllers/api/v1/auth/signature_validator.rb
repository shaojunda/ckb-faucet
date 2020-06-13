# frozen_string_literal: true

module Api
  module V1
    module Auth
      class SignatureValidator
        SERVICE_NAME = "faucet"
        ALGORITHM = "CKBFS1-HMAC-SHA256"
        TERMINATION_STR = "ckbfs1_request"

        attr_reader :request, :timestamp, :date, :secret_access_key, :signature

        def initialize(request, timestamp, secret_access_key, signature)
          @request = request
          @timestamp = timestamp
          @date = timestamp[0, 8]
          @secret_access_key = secret_access_key
          @signature = signature
        end

        def validate!
          raise Api::V1::ApiError::SignatureInvalidError unless valid?
        end

        def valid?
          signature == sign
        end

        def sign
          OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new("sha256"), signing_key, string_to_sign)
        end

        def signed_headers
          %w(host x-ckbfs-content-sha256 x-ckbfs-date).sort.join(";")
        end

        def credential_scope
          [
              date,
              SERVICE_NAME,
              TERMINATION_STR
          ].join("/")
        end

        def signing_key
          k_date = OpenSSL::HMAC.digest("sha256", "ckbfs1" + secret_access_key, date)
          k_service = OpenSSL::HMAC.digest("sha256", k_date, SERVICE_NAME)
          kSigning = OpenSSL::HMAC.digest("sha256", k_service, TERMINATION_STR)

          kSigning
        end

        def string_to_sign
          [
              ALGORITHM,
              timestamp,
              credential_scope,
              sha256_hexdigest(canonical_request)
          ].join("\n")
        end

        def canonical_request
          http_method = request.method
          canonical_uri = request.headers["host"]
          canonical_query_string = normalized_querystring(request.query_string)
          payload = request.body.read || ""
          request.body.rewind if payload.present?

          hashed_payload = sha256_hexdigest(payload)
          canonical_headers = %W[host:#{request.headers["host"]} x-ckbfs-content-sha256:#{hashed_payload} x-ckbfs-date:#{timestamp}].join("\n") + "\n"
          [
              http_method,
              canonical_uri,
              canonical_query_string,
              canonical_headers,
              signed_headers,
              hashed_payload
          ].join("\n")
        end

        def sha256_hexdigest(item)
          OpenSSL::Digest::SHA256.hexdigest(item)
        end

        def query_string_to_hash(query_string)
          key_values = query_string.split("&").inject({}) do |result, q|
            k, v = q.split("=")
            if !v.nil?
              result.merge({ k => v })
            elsif !result.key?(k)
              result.merge({ k => "" })
            else
              result
            end
          end

          key_values
        end

        def normalized_querystring(query_string)
          query_string_to_hash(query_string).map { |k, v| "#{k}=#{v}" }.sort.join("&")
        end
      end
    end
  end
end
