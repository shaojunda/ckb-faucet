# frozen_string_literal: true

require "test_helper"

class AuthenticatorTest < ActiveSupport::TestCase
  test "should raise error if authorization header is blank" do
    request = mock
    headers = { host: "domain.com" }.stringify_keys
    request.expects(:headers).returns(headers)
    authenticator = Api::V1::Auth::Authenticator.new(request)

    assert_raises Api::V1::ApiError::MissingAuthorizationHeaderError do
      authenticator.authenticate!
    end
  end

  test "should raise error if authorization header's algorithm is invalid" do
    request = mock
    headers = { host: "domain.com", authorization: "abc" }.stringify_keys
    request.expects(:headers).returns(headers)
    authenticator = Api::V1::Auth::Authenticator.new(request)

    assert_raises Api::V1::ApiError::AlgorithmFieldInvalidError do
      authenticator.authenticate!
    end
  end

  test "should raise error if authorization header's credential is missing" do
    request = mock
    headers = { host: "domain.com", authorization: "CKBFS1-HMAC-SHA256" }.stringify_keys
    request.expects(:headers).returns(headers)
    authenticator = Api::V1::Auth::Authenticator.new(request)

    assert_raises Api::V1::ApiError::CredentialFieldInvalidError do
      authenticator.authenticate!
    end
  end

  test "should raise error if authorization header credential filed's access key id is invalid" do
    request = mock
    headers = { host: "domain.com", authorization: "CKBFS1-HMAC-SHA256 Credential=2/20200611/faucet/ckbfs1_request" }.stringify_keys
    request.expects(:headers).returns(headers)
    authenticator = Api::V1::Auth::Authenticator.new(request)

    assert_raises Api::V1::ApiError::AccessKeyIdInvalidError do
      authenticator.authenticate!
    end
  end

  test "should raise error if can not found product by given access key id" do
    request = mock
    headers = { host: "domain.com", authorization: "CKBFS1-HMAC-SHA256 Credential=TYkNNrK4wjmche2i6WBAvajZ/20200611/faucet/ckbfs1_request" }.stringify_keys
    request.expects(:headers).returns(headers)
    authenticator = Api::V1::Auth::Authenticator.new(request)

    assert_raises Api::V1::ApiError::ProductNotFoundError do
      authenticator.authenticate!
    end
  end

  test "should raise error if signed headers is missing" do
    create(:product, access_key_id: "TYkNNrK4wjmche2i6WBAvajZ")
    request = mock
    headers = { host: "domain.com", authorization: "CKBFS1-HMAC-SHA256 Credential=TYkNNrK4wjmche2i6WBAvajZ/20200611/faucet/ckbfs1_request" }.stringify_keys
    request.expects(:headers).returns(headers)
    authenticator = Api::V1::Auth::Authenticator.new(request)

    assert_raises Api::V1::ApiError::SignedHeadersInvalidError do
      authenticator.authenticate!
    end
  end

  test "should raise error if signed headers is invalid" do
    create(:product, access_key_id: "TYkNNrK4wjmche2i6WBAvajZ")
    request = mock
    headers = { host: "domain.com", authorization: "CKBFS1-HMAC-SHA256 Credential=TYkNNrK4wjmche2i6WBAvajZ/20200611/faucet/ckbfs1_request, SignedHeader=host;x-ckbfs-date;x-ckbfs-content-sha256" }.stringify_keys
    request.expects(:headers).returns(headers)
    authenticator = Api::V1::Auth::Authenticator.new(request)

    assert_raises Api::V1::ApiError::SignedHeadersInvalidError do
      authenticator.authenticate!
    end
  end

  test "should raise error if signed headers's value is invalid" do
    create(:product, access_key_id: "TYkNNrK4wjmche2i6WBAvajZ")
    request = mock
    headers = { host: "domain.com", authorization: "CKBFS1-HMAC-SHA256 Credential=TYkNNrK4wjmche2i6WBAvajZ/20200611/faucet/ckbfs1_request, SignedHeaders=host;x-ckbfs-date;x-ckbfs-content-sha256" }.stringify_keys
    request.expects(:headers).returns(headers)
    authenticator = Api::V1::Auth::Authenticator.new(request)

    assert_raises Api::V1::ApiError::SignedHeadersInvalidError do
      authenticator.authenticate!
    end
  end

  test "should raise error if signature is missing" do
    create(:product, access_key_id: "TYkNNrK4wjmche2i6WBAvajZ")
    request = mock
    headers = { host: "domain.com", authorization: "CKBFS1-HMAC-SHA256 Credential=TYkNNrK4wjmche2i6WBAvajZ/20200611/faucet/ckbfs1_request, SignedHeaders=host;x-ckbfs-content-sha256;x-ckbfs-date" }.stringify_keys
    request.expects(:headers).returns(headers)
    authenticator = Api::V1::Auth::Authenticator.new(request)

    assert_raises Api::V1::ApiError::SignatureMissingError do
      authenticator.authenticate!
    end
  end

  test "should raise error if signature's value is missing" do
    create(:product, access_key_id: "TYkNNrK4wjmche2i6WBAvajZ")
    request = mock
    headers = { host: "domain.com", authorization: "CKBFS1-HMAC-SHA256 Credential=TYkNNrK4wjmche2i6WBAvajZ/20200611/faucet/ckbfs1_request, SignedHeaders=host;x-ckbfs-content-sha256;x-ckbfs-date, Signature=" }.stringify_keys
    request.expects(:headers).returns(headers)
    authenticator = Api::V1::Auth::Authenticator.new(request)

    assert_raises Api::V1::ApiError::SignatureMissingError do
      authenticator.authenticate!
    end
  end

  test "should raise error if x-ckbfs-date header is not set" do
    create(:product, access_key_id: "TYkNNrK4wjmche2i6WBAvajZ")
    request = mock
    headers = { host: "domain.com", authorization: "CKBFS1-HMAC-SHA256 Credential=TYkNNrK4wjmche2i6WBAvajZ/20200611/faucet/ckbfs1_request, SignedHeaders=host;x-ckbfs-content-sha256;x-ckbfs-date, Signature=ae0d663d2c9d437d35b753fe592947e21aefd1963d8b253776982438a9d46269" }.stringify_keys
    request.expects(:headers).returns(headers).at_least_once
    authenticator = Api::V1::Auth::Authenticator.new(request)

    assert_raises Api::V1::ApiError::DateHeaderMissingError do
      authenticator.authenticate!
    end
  end

  test "should raise error if request body is missing" do
    create(:product, access_key_id: "TYkNNrK4wjmche2i6WBAvajZ")
    request = mock
    headers = { "x-ckbfs-date": "20200611T130513Z", host: "domain.com", authorization: "CKBFS1-HMAC-SHA256 Credential=TYkNNrK4wjmche2i6WBAvajZ/20200611/faucet/ckbfs1_request, SignedHeaders=host;x-ckbfs-content-sha256;x-ckbfs-date, Signature=ae0d663d2c9d437d35b753fe592947e21aefd1963d8b253776982438a9d46269" }.stringify_keys
    request.expects(:headers).returns(headers).at_least_once
    type_script_args = "0x94bbc8327e16d195de87815c391e7b9131e80419c51a405a0b21227c6ee05129"
    pk160 = "0x69b7667edbe08cf19413102fcadc53c67e34fb71"
    request_body = {}.to_json
    body = StringIO.new(request_body)
    request.expects(:body).returns(body)
    authenticator = Api::V1::Auth::Authenticator.new(request)

    assert_raises Api::V1::ApiError::RequestBodyInvalidError do
      authenticator.authenticate!
    end
  end

  test "should raise error if resources object's type is not claim_event" do
    create(:product, access_key_id: "TYkNNrK4wjmche2i6WBAvajZ")
    request = mock
    headers = { "x-ckbfs-date": "20200611T130513Z", host: "domain.com", authorization: "CKBFS1-HMAC-SHA256 Credential=TYkNNrK4wjmche2i6WBAvajZ/20200611/faucet/ckbfs1_request, SignedHeaders=host;x-ckbfs-content-sha256;x-ckbfs-date, Signature=ae0d663d2c9d437d35b753fe592947e21aefd1963d8b253776982438a9d46269" }.stringify_keys
    request.expects(:headers).returns(headers).at_least_once
    type_script_args = "0x94bbc8327e16d195de87815c391e7b9131e80419c51a405a0b21227c6ee05129"
    pk160 = "0x69b7667edbe08cf19413102fcadc53c67e34fb71"
    request_body = { data: { id: 1, type: "ok", attributes: {
        request_uuid: type_script_args, request_type: 0, pk160: pk160
    } } }.to_json
    body = StringIO.new(request_body)
    request.expects(:body).returns(body)
    authenticator = Api::V1::Auth::Authenticator.new(request)

    assert_raises Api::V1::ApiError::RequestBodyInvalidError do
      authenticator.authenticate!
    end
  end

  test "should raise error if resources object's root key is not just data" do
    create(:product, access_key_id: "TYkNNrK4wjmche2i6WBAvajZ")
    request = mock
    headers = { "x-ckbfs-date": "20200611T130513Z", host: "domain.com", authorization: "CKBFS1-HMAC-SHA256 Credential=TYkNNrK4wjmche2i6WBAvajZ/20200611/faucet/ckbfs1_request, SignedHeaders=host;x-ckbfs-content-sha256;x-ckbfs-date, Signature=ae0d663d2c9d437d35b753fe592947e21aefd1963d8b253776982438a9d46269" }.stringify_keys
    request.expects(:headers).returns(headers).at_least_once
    type_script_args = "0x94bbc8327e16d195de87815c391e7b9131e80419c51a405a0b21227c6ee05129"
    pk160 = "0x69b7667edbe08cf19413102fcadc53c67e34fb71"
    request_body = { data1: {}, data: { id: 1, type: "claim_event", attributes: {
        request_uuid: type_script_args, request_type: 0, pk160: pk160
    } } }.to_json
    body = StringIO.new(request_body)
    request.expects(:body).returns(body)
    authenticator = Api::V1::Auth::Authenticator.new(request)

    assert_raises Api::V1::ApiError::RequestBodyInvalidError do
      authenticator.authenticate!
    end
  end

  test "should raise error if resources object's root key is not data" do
    create(:product, access_key_id: "TYkNNrK4wjmche2i6WBAvajZ")
    request = mock
    headers = { "x-ckbfs-date": "20200611T130513Z", host: "domain.com", authorization: "CKBFS1-HMAC-SHA256 Credential=TYkNNrK4wjmche2i6WBAvajZ/20200611/faucet/ckbfs1_request, SignedHeaders=host;x-ckbfs-content-sha256;x-ckbfs-date, Signature=ae0d663d2c9d437d35b753fe592947e21aefd1963d8b253776982438a9d46269" }.stringify_keys
    request.expects(:headers).returns(headers).at_least_once
    type_script_args = "0x94bbc8327e16d195de87815c391e7b9131e80419c51a405a0b21227c6ee05129"
    pk160 = "0x69b7667edbe08cf19413102fcadc53c67e34fb71"
    request_body = { data1: { id: 1, type: "claim_event", attributes: {
        request_uuid: type_script_args, request_type: 0, pk160: pk160
    } } }.to_json
    body = StringIO.new(request_body)
    request.expects(:body).returns(body)
    authenticator = Api::V1::Auth::Authenticator.new(request)

    assert_raises Api::V1::ApiError::RequestBodyInvalidError do
      authenticator.authenticate!
    end
  end

  test "should raise error when pk160 is missing" do
    create(:product, access_key_id: "TYkNNrK4wjmche2i6WBAvajZ")
    request = mock
    headers = { "x-ckbfs-date": "20200611T130513Z", host: "domain.com", authorization: "CKBFS1-HMAC-SHA256 Credential=TYkNNrK4wjmche2i6WBAvajZ/20200611/faucet/ckbfs1_request, SignedHeaders=host;x-ckbfs-content-sha256;x-ckbfs-date, Signature=ae0d663d2c9d437d35b753fe592947e21aefd1963d8b253776982438a9d46269" }.stringify_keys
    request.expects(:headers).returns(headers).at_least_once
    type_script_args = "0x94bbc8327e16d195de87815c391e7b9131e80419c51a405a0b21227c6ee05129"
    request_body = { data: { id: 1, type: "claim_event", attributes: {
        request_uuid: type_script_args, request_type: 0
    } } }.to_json
    body = StringIO.new(request_body)
    request.expects(:body).returns(body)
    authenticator = Api::V1::Auth::Authenticator.new(request)

    assert_raises Api::V1::ApiError::RequestBodyInvalidError do
      authenticator.authenticate!
    end
  end

  test "should raise error when request_uuid is missing" do
    create(:product, access_key_id: "TYkNNrK4wjmche2i6WBAvajZ")
    request = mock
    headers = { "x-ckbfs-date": "20200611T130513Z", host: "domain.com", authorization: "CKBFS1-HMAC-SHA256 Credential=TYkNNrK4wjmche2i6WBAvajZ/20200611/faucet/ckbfs1_request, SignedHeaders=host;x-ckbfs-content-sha256;x-ckbfs-date, Signature=ae0d663d2c9d437d35b753fe592947e21aefd1963d8b253776982438a9d46269" }.stringify_keys
    request.expects(:headers).returns(headers).at_least_once
    pk160 = "0x69b7667edbe08cf19413102fcadc53c67e34fb71"
    request_body = { data: { id: 1, type: "claim_event", attributes: {
        request_type: 0, pk160: pk160
    } } }.to_json
    body = StringIO.new(request_body)
    request.expects(:body).returns(body)
    authenticator = Api::V1::Auth::Authenticator.new(request)

    assert_raises Api::V1::ApiError::RequestBodyInvalidError do
      authenticator.authenticate!
    end
  end

  test "should raise error when request_type is missing" do
    create(:product, access_key_id: "TYkNNrK4wjmche2i6WBAvajZ")
    request = mock
    headers = { "x-ckbfs-date": "20200611T130513Z", host: "domain.com", authorization: "CKBFS1-HMAC-SHA256 Credential=TYkNNrK4wjmche2i6WBAvajZ/20200611/faucet/ckbfs1_request, SignedHeaders=host;x-ckbfs-content-sha256;x-ckbfs-date, Signature=ae0d663d2c9d437d35b753fe592947e21aefd1963d8b253776982438a9d46269" }.stringify_keys
    request.expects(:headers).returns(headers).at_least_once
    type_script_args = "0x94bbc8327e16d195de87815c391e7b9131e80419c51a405a0b21227c6ee05129"
    pk160 = "0x69b7667edbe08cf19413102fcadc53c67e34fb71"
    request_body = { data1: { id: 1, type: "claim_event", attributes: {
        request_uuid: type_script_args, pk160: pk160
    } } }.to_json
    body = StringIO.new(request_body)
    request.expects(:body).returns(body)
    authenticator = Api::V1::Auth::Authenticator.new(request)

    assert_raises Api::V1::ApiError::RequestBodyInvalidError do
      authenticator.authenticate!
    end
  end

  test "should raise error when request body format is invalid" do
    create(:product, access_key_id: "TYkNNrK4wjmche2i6WBAvajZ")
    request = mock
    headers = { "x-ckbfs-date": "20200611T130513Z", host: "domain.com", authorization: "CKBFS1-HMAC-SHA256 Credential=TYkNNrK4wjmche2i6WBAvajZ/20200611/faucet/ckbfs1_request, SignedHeaders=host;x-ckbfs-content-sha256;x-ckbfs-date, Signature=ae0d663d2c9d437d35b753fe592947e21aefd1963d8b253776982438a9d46269" }.stringify_keys
    request.expects(:headers).returns(headers).at_least_once
    type_script_args = "0x94bbc8327e16d195de87815c391e7b9131e80419c51a405a0b21227c6ee05129"
    pk160 = "0x69b7667edbe08cf19413102fcadc53c67e34fb71"
    request_body = { data1: { id: 1, type: "claim_event", attributes: {
        request_uuid: type_script_args, pk160: pk160
    } } }.to_json
    body = StringIO.new(request_body+"}")
    request.expects(:body).returns(body)
    authenticator = Api::V1::Auth::Authenticator.new(request)

    assert_raises Api::V1::ApiError::RequestBodyInvalidError do
      authenticator.authenticate!
    end
  end

  test "should raise error if the request performed exceeds 5 minutes" do
    create(:product, access_key_id: "TYkNNrK4wjmche2i6WBAvajZ")
    request = mock
    headers = { "x-ckbfs-date": "20200611T130513Z", host: "domain.com", authorization: "CKBFS1-HMAC-SHA256 Credential=TYkNNrK4wjmche2i6WBAvajZ/20200611/faucet/ckbfs1_request, SignedHeaders=host;x-ckbfs-content-sha256;x-ckbfs-date, Signature=ae0d663d2c9d437d35b753fe592947e21aefd1963d8b253776982438a9d46269" }.stringify_keys
    request.expects(:headers).returns(headers).at_least_once
    type_script_args = "0x94bbc8327e16d195de87815c391e7b9131e80419c51a405a0b21227c6ee05129"
    pk160 = "0x69b7667edbe08cf19413102fcadc53c67e34fb71"
    request_body = { data: { id: 1, type: "claim_event", attributes: {
        request_uuid: type_script_args, request_type: 0, pk160: pk160
    } } }.to_json
    body = StringIO.new(request_body)
    request.expects(:body).returns(body)
    authenticator = Api::V1::Auth::Authenticator.new(request)

    assert_raises Api::V1::ApiError::TimestampInvalidError do
      authenticator.authenticate!
    end
  end
end
