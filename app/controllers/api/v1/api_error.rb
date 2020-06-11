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
          super(code: 1002, status: 401, title: "Credential field is invalid", detail: "Credential field format is Credential=<Access Key ID/Scope>", href: "")
        end
      end

      class AccessKeyIdInvalidError < ApiError
        def initialize
          super(code: 1002, status: 401, title: "Access Key Id is invalid", detail: "Access Key Id must be 24 characters long", href: "")
        end
      end

      class ProductNotFoundError < ApiError
        def initialize
          super(code: 1002, status: 401, title: "Product not found", detail: "No product found by given access key id", href: "")
        end
      end
    end
  end
end
