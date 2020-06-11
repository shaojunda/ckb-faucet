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
    end
  end
end
