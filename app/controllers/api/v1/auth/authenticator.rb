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
          check_signature!
        end

        private
          attr_accessor :request, :claim_event_params, :access_key_id, :signature, :timestamp

          def check_signature!
            canonical_request = canonical_request(request, timestamp)
            string_to_sign = string_to_sign(timestamp, canonical_request)
            signing_key = signature_key(product.secret_access_key, timestamp[0, 8], service_name)
            raise Api::V1::ApiError::SignatureInvalidError if signature != sign(signing_key, string_to_sign)
          end

          def check_timestamp!
            tolerant_time = 5.minutes
            @timestamp = request.headers["x-ckbfs-date"]
            raise Api::V1::ApiError::TimestampInvalidError if (Time.now.utc.to_i - timestamp.in_time_zone("UTC").to_i).abs > tolerant_time
          end

          def check_body!
            request_body = JSON.parse(request.body.read)
            request.body.rewind
            if request_body.keys.size != 1 || request_body.keys.first != "data" || request_body.dig("data").keys.sort != %w(attributes id type) ||
                request_body.dig("data", "type") != "claim_event" || request_body.dig("data", "attributes").keys.sort != %w(request_uuid request_type pk160).sort
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
            @signature = signature_values[1]
          end

          def product
            @product ||= Product.find_by(access_key_id: access_key_id)
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
