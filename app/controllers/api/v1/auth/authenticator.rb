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

          product
        end

        private
          attr_accessor :request, :claim_event_params, :timestamp

          def check_signature!
            canonical_request = canonical_request(request, timestamp)
            string_to_sign = string_to_sign(timestamp, canonical_request)
            signing_key = signature_key(product.secret_access_key, timestamp[0, 8], service_name)
            raise Api::V1::ApiError::SignatureInvalidError if signature != sign(signing_key, string_to_sign)
          end

          def check_timestamp!
            TimestampValidator.new(timestamp).validate!
          end

          def check_body!
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
            @product ||= Product.find_by(access_key_id: access_key_id)
          end

          def signature
            authorization = request.headers["authorization"]
            target_key = "Signature="
            credential_index = authorization.index(target_key) + target_key.size
            authorization[credential_index..-1]
          end

          def access_key_id
            authorization = request.headers["authorization"]
            target_key = "Credential="
            credential_index = authorization.index(target_key) + target_key.size
            authorization[credential_index, 24]
          end

          def authorization(credential, signature)
            [
                "#{algorithm} Credential=#{credential}",
                "SignedHeaders=#{signed_headers}",
                "Signature=#{signature}"
            ].join(", ")
          end

          def algorithm
            "CKBFS1-HMAC-SHA256"
          end

          def credential(access_key_id, date)
            [
                access_key_id,
                credential_scope(date)
            ].join("/")
          end

          def signed_headers
            %w(host x-ckbfs-content-sha256 x-ckbfs-date).sort.join(";")
          end

          def canonical_request(request, timestamp)
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

          def service_name
            "faucet"
          end

          def credential_scope(date)
            [
                date,
                service_name,
                "ckbfs1_request"
            ].join("/")
          end

          def string_to_sign(timestamp, canonical_request)
            date = timestamp[0, 8]
            [
                algorithm,
                timestamp,
                credential_scope(date),
                sha256_hexdigest(canonical_request)
            ].join("\n")
          end

          def sign(signing_key, string_to_sign)
            OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new("sha256"), signing_key, string_to_sign)
          end

          def signature_key(secret_access_key, date, service_name)
            k_date = OpenSSL::HMAC.digest("sha256", "ckbfs1" + secret_access_key, date)
            k_service = OpenSSL::HMAC.digest("sha256", k_date, service_name)
            kSigning = OpenSSL::HMAC.digest("sha256", k_service, "ckbfs1_request")

            kSigning
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
