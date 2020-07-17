# frozen_string_literal: true

module Api
  module V1
    class ApiError < StandardError
      attr_accessor :code, :status, :title, :detail, :href

      def initialize(code:, status:, title:, detail:, href:)
        @code = code
        @status = status
        @title = title
        @detail = detail
        @href = href
      end

      class MissingAuthorizationHeaderError < ApiError
        def initialize
          super(code: 1001, status: 401, title: "Authorization header is required", detail: "Need to set authorization HTTP header", href: "")
        end
      end

      class AlgorithmFieldInvalidError < ApiError
        def initialize
          super(code: 1002, status: 401, title: "Algorithm field is invalid", detail: "Algorithm field must be CKBFS1-HMAC-SHA256", href: "")
        end
      end

      class CredentialFieldInvalidError < ApiError
        def initialize
          super(code: 1003, status: 401, title: "Credential field is invalid", detail: "Credential field format is Credential=<Access Key ID/Scope>", href: "")
        end
      end

      class AccessKeyIdInvalidError < ApiError
        def initialize
          super(code: 1004, status: 401, title: "Access Key Id is invalid", detail: "Access Key Id must be 24 characters long", href: "")
        end
      end

      class ProductNotFoundError < ApiError
        def initialize
          super(code: 1005, status: 401, title: "Product not found", detail: "No product found by given access key id", href: "")
        end
      end

      class SignedHeadersInvalidError < ApiError
        def initialize
          super(code: 1006, status: 401, title: "SignedHeaders is invalid", detail: "SignedHeaders format is SignedHeaders=host;x-ckbfs-date;x-ckbfs-content-sha256", href: "")
        end
      end

      class SignatureMissingError < ApiError
        def initialize
          super(code: 1007, status: 401, title: "Signature is invalid", detail: "Signature format is Signature=<Signature>", href: "")
        end
      end

      class DateHeaderMissingError < ApiError
        def initialize
          super(code: 1008, status: 401, title: "x-ckbfs-date header is required", detail: "x-ckbfs-date header format is UTC time in ISO 8601 basic format, eg: 20200611T130513Z", href: "")
        end
      end

      class RequestBodyInvalidError < ApiError
        def initialize
          super(code: 1009, status: 401, title: "Request body is invalid", detail: "Request body type is Resource objects and it's attributes must contain (request_uuid, id, request_type, and pk160)", href: "https://jsonapi.org/format/#crud")
        end
      end

      class TimestampInvalidError < ApiError
        def initialize
          super(code: 1010, status: 401, title: "Timestamp is invalid", detail: "Your request must be performed within 5 minutes of the specified timestamp", href: "")
        end
      end

      class SignatureInvalidError < ApiError
        def initialize
          super(code: 1011, status: 401, title: "Signature is invalid", detail: "The request signature we calculated does not match the signature you provided. Check your Secret Access Key and signing method. Consult the service documentation for details.", href: "")
        end
      end

      class ServiceInvalidError < ApiError
        def initialize
          super(code: 1012, status: 401, title: "Service is invalid", detail: "Currently the service name only supports 'faucet'", href: "")
        end
      end

      class ContentTypeInvalidError < ApiError
        def initialize
          super(code: 1003, status: 415, title: "Unsupported Media Type", detail: "Content Type must be application/vnd.api+json", href: "")
        end
      end

      class AcceptInvalidError < ApiError
        def initialize
          super(code: 1004, status: 406, title: "Not Acceptable", detail: "Accept must be application/vnd.api+json", href: "")
        end
      end

      class ExceedsDailyQuotaLimitPerProductError < ApiError
        def initialize
          super(code: 1005, status: 422, title: "Exceeds daily quota limit", detail: "Exceeds daily quota limit", href: "")
        end
      end

      class ExceedsDailyQuotaLimitPerTypeError < ApiError
        def initialize
          super(code: 1006, status: 422, title: "Exceeds daily per type quota limit", detail: "Exceeds daily per type quota limit", href: "")
        end
      end

      class ExceedsDailyQuotaLimitError < ApiError
        def initialize
          super(code: 1007, status: 422, title: "Exceeds daily total quota limit", detail: "Exceeds daily total quota limit", href: "")
        end
      end

      class RequestTypeInvalidError < ApiError
        def initialize
          super(code: 1008, status: 422, title: "Request type invalid error", detail: "Request type only support 0 or 1 for now", href: "")
        end
      end

      class ClaimEventNotFoundError < ApiError
        def initialize
          super(code: 1009, status: 404, title: "Claim event not found", detail: "No claim event record found by given id", href: "")
        end
      end

      class RequestUUIDInvalidError < ApiError
        def initialize
          super(code: 1010, status: 422, title: "Request UUID invalid error", detail: "The request_uuid should be the args of the type script", href: "")
        end
      end

      class Pk160InvalidError < ApiError
        def initialize
          super(code: 1011, status: 422, title: "Pk160 invalid error", detail: "The pk160 should be the args of the lock script", href: "")
        end
      end
    end
  end
end
