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

  test "should raise error if authorization header's algorithm is invalid" do
    request = mock
    headers = { host: "domain.com", authorization: "abc" }.stringify_keys
    request.expects(:headers).returns(headers)
    authenticator = Api::V1::Auth::Authenticator.new(request, {})

    assert_raises Api::V1::ApiError::AlgorithmFieldInvalidError do
      authenticator.authenticate!
    end
  end

  test "should raise error if authorization header's credential is missing" do
    request = mock
    headers = { host: "domain.com", authorization: "CKBFS1-HMAC-SHA256 SignedHeaders=host;x-ckbfs-content-sha256;x-ckbfs-date" }.stringify_keys
    request.expects(:headers).returns(headers)
    authenticator = Api::V1::Auth::Authenticator.new(request, {})

    assert_raises Api::V1::ApiError::CredentialFieldInvalidError do
      authenticator.authenticate!
    end
  end

  test "should raise error if authorization header credential filed's access key id is invalid" do
    request = mock
    headers = { host: "domain.com", authorization: "CKBFS1-HMAC-SHA256 Credential=2/20200611/faucet/ckbfs1_request" }.stringify_keys
    request.expects(:headers).returns(headers)
    authenticator = Api::V1::Auth::Authenticator.new(request, {})

    assert_raises Api::V1::ApiError::AccessKeyIdInvalidError do
      authenticator.authenticate!
    end
  end

  test "should raise error if can not found product by given access key id" do
    request = mock
    headers = { host: "domain.com", authorization: "CKBFS1-HMAC-SHA256 Credential=TYkNNrK4wjmche2i6WBAvajZ/20200611/faucet/ckbfs1_request" }.stringify_keys
    request.expects(:headers).returns(headers)
    authenticator = Api::V1::Auth::Authenticator.new(request, {})

    assert_raises Api::V1::ApiError::ProductNotFoundError do
      authenticator.authenticate!
    end
  end

  test "should raise error if signed headers is invalid" do
    create(:product, access_key_id: "TYkNNrK4wjmche2i6WBAvajZ")
    request = mock
    headers = { host: "domain.com", authorization: "CKBFS1-HMAC-SHA256 Credential=TYkNNrK4wjmche2i6WBAvajZ/20200611/faucet/ckbfs1_request, SignedHeaders=host;x-ckbfs-date;x-ckbfs-content-sha256" }.stringify_keys
    request.expects(:headers).returns(headers)
    authenticator = Api::V1::Auth::Authenticator.new(request, {})

    assert_raises Api::V1::ApiError::SignedHeadersInvalidError do
      authenticator.authenticate!
    end
  end

  test "should raise error if signature is missing" do
    create(:product, access_key_id: "TYkNNrK4wjmche2i6WBAvajZ")
    request = mock
    headers = { host: "domain.com", authorization: "CKBFS1-HMAC-SHA256 Credential=TYkNNrK4wjmche2i6WBAvajZ/20200611/faucet/ckbfs1_request, SignedHeaders=host;x-ckbfs-date;x-ckbfs-content-sha256" }.stringify_keys
    request.expects(:headers).returns(headers)
    authenticator = Api::V1::Auth::Authenticator.new(request, {})

    assert_raises Api::V1::ApiError::SignatureMissingError do
      authenticator.authenticate!
    end
  end

  test "should raise error if signature's value is missing" do
    create(:product, access_key_id: "TYkNNrK4wjmche2i6WBAvajZ")
    request = mock
    headers = { host: "domain.com", authorization: "CKBFS1-HMAC-SHA256 Credential=TYkNNrK4wjmche2i6WBAvajZ/20200611/faucet/ckbfs1_request, SignedHeaders=host;x-ckbfs-date;x-ckbfs-content-sha256, Signature=" }.stringify_keys
    request.expects(:headers).returns(headers)
    authenticator = Api::V1::Auth::Authenticator.new(request, {})

    assert_raises Api::V1::ApiError::SignatureMissingError do
      authenticator.authenticate!
    end
  end
end
