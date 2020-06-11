# frozen_string_literal: true

require "test_helper"

class AuthenticatorTest < ActiveSupport::TestCase
  test "should raise error if authorization header is blank" do
    request = mock
    headers = { host: "domain.com" }.stringify_keys
    request.expects(:headers).returns(headers).at_least_once
    authenticator = Api::V1::Auth::Authenticator.new(request)

    assert_raises Api::V1::ApiError::MissingAuthorizationHeaderError do
      authenticator.authenticate!
    end
  end

  test "should raise error if authorization header's algorithm is invalid" do
    request = mock
    headers = { host: "domain.com", authorization: "abc" }.stringify_keys
    request.expects(:headers).returns(headers).at_least_once
    authenticator = Api::V1::Auth::Authenticator.new(request)

    assert_raises Api::V1::ApiError::AlgorithmFieldInvalidError do
      authenticator.authenticate!
    end
  end

  test "should raise error if authorization header's credential is missing" do
    request = mock
    headers = { host: "domain.com", authorization: "CKBFS1-HMAC-SHA256" }.stringify_keys
    request.expects(:headers).returns(headers).at_least_once
    authenticator = Api::V1::Auth::Authenticator.new(request)

    assert_raises Api::V1::ApiError::CredentialFieldInvalidError do
      authenticator.authenticate!
    end
  end

  test "should raise error if authorization header credential filed's access key id is invalid" do
    request = mock
    headers = { host: "domain.com", authorization: "CKBFS1-HMAC-SHA256 Credential=2/20200611/faucet/ckbfs1_request" }.stringify_keys
    request.expects(:headers).returns(headers).at_least_once
    authenticator = Api::V1::Auth::Authenticator.new(request)

    assert_raises Api::V1::ApiError::AccessKeyIdInvalidError do
      authenticator.authenticate!
    end
  end

  test "should raise error if can not found product by given access key id" do
    request = mock
    headers = { host: "domain.com", authorization: "CKBFS1-HMAC-SHA256 Credential=TYkNNrK4wjmche2i6WBAvajZ/20200611/faucet/ckbfs1_request" }.stringify_keys
    request.expects(:headers).returns(headers).at_least_once
    authenticator = Api::V1::Auth::Authenticator.new(request)

    assert_raises Api::V1::ApiError::ProductNotFoundError do
      authenticator.authenticate!
    end
  end

  test "should raise error if signed headers is missing" do
    create(:product, access_key_id: "TYkNNrK4wjmche2i6WBAvajZ")
    request = mock
    headers = { host: "domain.com", authorization: "CKBFS1-HMAC-SHA256 Credential=TYkNNrK4wjmche2i6WBAvajZ/20200611/faucet/ckbfs1_request" }.stringify_keys
    request.expects(:headers).returns(headers).at_least_once
    authenticator = Api::V1::Auth::Authenticator.new(request)

    assert_raises Api::V1::ApiError::SignedHeadersInvalidError do
      authenticator.authenticate!
    end
  end

  test "should raise error if signed headers is invalid" do
    create(:product, access_key_id: "TYkNNrK4wjmche2i6WBAvajZ")
    request = mock
    headers = { host: "domain.com", authorization: "CKBFS1-HMAC-SHA256 Credential=TYkNNrK4wjmche2i6WBAvajZ/20200611/faucet/ckbfs1_request, SignedHeader=host;x-ckbfs-date;x-ckbfs-content-sha256" }.stringify_keys
    request.expects(:headers).returns(headers).at_least_once
    authenticator = Api::V1::Auth::Authenticator.new(request)

    assert_raises Api::V1::ApiError::SignedHeadersInvalidError do
      authenticator.authenticate!
    end
  end

  test "should raise error if signed headers's value is invalid" do
    create(:product, access_key_id: "TYkNNrK4wjmche2i6WBAvajZ")
    request = mock
    headers = { host: "domain.com", authorization: "CKBFS1-HMAC-SHA256 Credential=TYkNNrK4wjmche2i6WBAvajZ/20200611/faucet/ckbfs1_request, SignedHeaders=host;x-ckbfs-date;x-ckbfs-content-sha256" }.stringify_keys
    request.expects(:headers).returns(headers).at_least_once
    authenticator = Api::V1::Auth::Authenticator.new(request)

    assert_raises Api::V1::ApiError::SignedHeadersInvalidError do
      authenticator.authenticate!
    end
  end

  test "should raise error if signature is missing" do
    create(:product, access_key_id: "TYkNNrK4wjmche2i6WBAvajZ")
    request = mock
    headers = { host: "domain.com", authorization: "CKBFS1-HMAC-SHA256 Credential=TYkNNrK4wjmche2i6WBAvajZ/20200611/faucet/ckbfs1_request, SignedHeaders=host;x-ckbfs-content-sha256;x-ckbfs-date" }.stringify_keys
    request.expects(:headers).returns(headers).at_least_once
    authenticator = Api::V1::Auth::Authenticator.new(request)

    assert_raises Api::V1::ApiError::SignatureMissingError do
      authenticator.authenticate!
    end
  end

  test "should raise error if signature's value is missing" do
    create(:product, access_key_id: "TYkNNrK4wjmche2i6WBAvajZ")
    request = mock
    headers = { host: "domain.com", authorization: "CKBFS1-HMAC-SHA256 Credential=TYkNNrK4wjmche2i6WBAvajZ/20200611/faucet/ckbfs1_request, SignedHeaders=host;x-ckbfs-content-sha256;x-ckbfs-date, Signature=" }.stringify_keys
    request.expects(:headers).returns(headers).at_least_once
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
    request.expects(:body).returns(body).at_least_once
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
    request.expects(:body).returns(body).at_least_once
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
    request.expects(:body).returns(body).at_least_once
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
    request.expects(:body).returns(body).at_least_once
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
    request.expects(:body).returns(body).at_least_once
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
    request.expects(:body).returns(body).at_least_once
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
    request.expects(:body).returns(body).at_least_once
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
    request.expects(:body).returns(body).at_least_once
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
    request.expects(:body).returns(body).at_least_once
    authenticator = Api::V1::Auth::Authenticator.new(request)

    assert_raises Api::V1::ApiError::TimestampInvalidError do
      authenticator.authenticate!
    end
  end

  test "should raise error if the signature is invalid" do
    product = create(:product, access_key_id: "TYkNNrK4wjmche2i6WBAvajZ")
    request = mock
    timestamp = Time.now.utc.strftime("%Y%m%dT%H%M%SZ")
    date = timestamp[0, 8]
    headers = { "x-ckbfs-date": timestamp, host: "domain.com", authorization: "CKBFS1-HMAC-SHA256 Credential=TYkNNrK4wjmche2i6WBAvajZ/20200611/faucet/ckbfs1_request, SignedHeaders=host;x-ckbfs-content-sha256;x-ckbfs-date, Signature=ae0d663d2c9d437d35b753fe592947e21aefd1963d8b253776982438a9d46269" }.stringify_keys
    request.expects(:headers).returns(headers).at_least_once
    request.expects(:query_string).returns("").at_least_once
    request.expects(:method).returns("POST").at_least_once
    type_script_args = "0x94bbc8327e16d195de87815c391e7b9131e80419c51a405a0b21227c6ee05129"
    pk160 = "0x69b7667edbe08cf19413102fcadc53c67e34fb71"
    request_body = { data: { id: 1, type: "claim_event", attributes: {
        request_uuid: type_script_args, request_type: 0, pk160: pk160
    } } }.to_json
    body = StringIO.new(request_body)
    request.expects(:body).returns(body).at_least_once
    canonical_request = canonical_request(request, timestamp)
    string_to_sign = string_to_sign(timestamp, canonical_request)
    signing_key = signature_key(product.secret_access_key, date, service_name)
    signature = "abc"
    credential = credential(product.access_key_id, date)
    headers["authorization"] = authorization(credential, signature)
    request.expects(:headers).returns(headers).at_least_once
    authenticator = Api::V1::Auth::Authenticator.new(request)
    assert_raises Api::V1::ApiError::SignatureInvalidError do
      authenticator.authenticate!
    end
  end

  private
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

    def signature(signing_key, string_to_sign)
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
