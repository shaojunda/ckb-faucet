# frozen_string_literal: true

require "test_helper"

class AuthenticatorTest < ActiveSupport::TestCase
  test "should raise error if authorization header is blank" do
    request = mock
    headers = { host: "domain.com" }.stringify_keys
    request.expects(:headers).returns(headers)
    authenticator = Api::V1::Auth::Authenticator.new(request, {})

    assert_raises Api::V1::ApiError::MissingAuthorizationHeaderError do
      authenticator.authenticate!
    end
  end
end
