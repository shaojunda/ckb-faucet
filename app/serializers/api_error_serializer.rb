# frozen_string_literal: true

class ApiErrorSerializer
  include FastJsonapi::ErrorSerializer

  attributes :title, :detail, :code, :status
end
