# frozen_string_literal: true

require "test_helper"

class Api::V1::ClaimEventsControllerTest < ActionDispatch::IntegrationTest
  setup do
    host! "domain.com"
  end

  test "should set right content type when call create" do
    type_script_args = "0x94bbc8327e16d195de87815c391e7b9131e80419c51a405a0b21227c6ee05129"
    pk160 = "0x69b7667edbe08cf19413102fcadc53c67e34fb71"
    request_body = { data: { id: 1, type: "claim_event", attributes: {
        request_uuid: type_script_args, request_type: 0, pk160: pk160
    } } }.to_json

    valid_post api_v1_claim_events_url, params: request_body

    assert_equal "application/vnd.api+json", response.media_type
  end

  test "should respond with 415 Unsupported Media Type when call create and Content-Type is wrong" do
    post api_v1_claim_events_url, headers: { "Content-Type": "text/plain" }

    assert_equal 415, response.status
  end

  test "should respond with error object when call create and Content-Type is wrong" do
    error_object = Api::V1::ApiError::ContentTypeInvalidError.new
    response_json = ApiErrorSerializer.new([error_object], message: error_object.title).serialized_json

    post api_v1_claim_events_url, headers: { "Content-Type": "text/plain" }

    assert_equal response_json, response.body
  end

  test "should respond with 406 Not Acceptable when call create and Accept is wrong" do
    post api_v1_claim_events_url, headers: { "Content-Type": "application/vnd.api+json", "Accept": "application/json" }

    assert_equal 406, response.status
  end

  test "should respond with error object when call create and Accept is wrong" do
    error_object = Api::V1::ApiError::AcceptInvalidError.new
    response_json = ApiErrorSerializer.new([error_object], message: error_object.title).serialized_json

    post api_v1_claim_events_url, headers: { "Content-Type": "application/vnd.api+json", "Accept": "application/json" }

    assert_equal response_json, response.body
  end

  test "should pass the authentication check before call create" do
    type_script_args = "0x94bbc8327e16d195de87815c391e7b9131e80419c51a405a0b21227c6ee05129"
    pk160 = "0x69b7667edbe08cf19413102fcadc53c67e34fb71"
    request_body = { data: { id: 1, type: "claim_event", attributes: {
        request_uuid: type_script_args, request_type: 0, pk160: pk160
    } } }.to_json
    error_object = Api::V1::ApiError::MissingAuthorizationHeaderError.new
    response_json = ApiErrorSerializer.new([error_object], message: error_object.title).serialized_json

    valid_post api_v1_claim_events_url, params: request_body

    assert_equal response_json, response.body
  end

  test "should return error object when one product's claim count exceeds the quota limit" do
    product = create(:product, quota_config: { "h24_quota": 4, "h24_quota_per_request_type": 2 })
    create_list(:claim_event, 2, product: product, request_type: 0)
    create_list(:claim_event, 2, product: product, request_type: 1)
    type_script_args = "0x94bbc8327e16d195de87815c391e7b9131e80419c51a405a0b21227c6ee05129"
    pk160 = "0x69b7667edbe08cf19413102fcadc53c67e34fb71"
    request_body = { data: { id: 1, type: "claim_event", attributes: {
        request_uuid: type_script_args, request_type: 0, pk160: pk160, acp_type: "new"
    } } }.to_json
    error_object = Api::V1::ApiError::ExceedsDailyQuotaLimitPerProductError.new
    response_json = ApiErrorSerializer.new([error_object], message: error_object.title).serialized_json
    timestamp = Time.now.utc.strftime("%Y%m%dT%H%M%SZ")
    request = mock
    body = StringIO.new(request_body)
    headers = { "x-ckbfs-date": timestamp, host: "domain.com" }.stringify_keys
    request.expects(:headers).returns(headers).at_least_once
    request.expects(:query_string).returns("").at_least_once
    request.expects(:method).returns("POST").at_least_once
    request.expects(:body).returns(body).at_least_once

    valid_post api_v1_claim_events_url, params: request_body, headers: { "x-ckbfs-date": timestamp, "authorization": authorization(request, timestamp, product) }

    assert_equal response_json, response.body
  end

  test "should return error object when one product's claim count for one type exceeds the quota limit" do
    product = create(:product, quota_config: { "h24_quota": 4, "h24_quota_per_request_type": 2 })
    create_list(:claim_event, 2, product: product, request_type: 0)
    type_script_args = "0x94bbc8327e16d195de87815c391e7b9131e80419c51a405a0b21227c6ee05129"
    pk160 = "0x69b7667edbe08cf19413102fcadc53c67e34fb71"
    request_body = { data: { id: 1, type: "claim_event", attributes: {
        request_uuid: type_script_args, request_type: 0, pk160: pk160, acp_type: "new"
    } } }.to_json
    error_object = Api::V1::ApiError::ExceedsDailyQuotaLimitPerTypeError.new
    response_json = ApiErrorSerializer.new([error_object], message: error_object.title).serialized_json
    timestamp = Time.now.utc.strftime("%Y%m%dT%H%M%SZ")
    request = mock
    body = StringIO.new(request_body)
    headers = { "x-ckbfs-date": timestamp, host: "domain.com" }.stringify_keys
    request.expects(:headers).returns(headers).at_least_once
    request.expects(:query_string).returns("").at_least_once
    request.expects(:method).returns("POST").at_least_once
    request.expects(:body).returns(body).at_least_once

    valid_post api_v1_claim_events_url, params: request_body, headers: { "x-ckbfs-date": timestamp, "authorization": authorization(request, timestamp, product) }

    assert_equal response_json, response.body
  end

  test "should return error object when claim count exceeds the total quota limit" do
    product = create(:product, quota_config: { "h24_quota": 4, "h24_quota_per_request_type": 2 })
    product1 = create(:product, name: "KFC1", quota_config: { "h24_quota": 2, "h24_quota_per_request_type": 1 })
    create_list(:claim_event, 2, product: product, request_type: 0)
    create_list(:claim_event, 2, product: product, request_type: 1)
    create(:claim_event, product: product1, request_type: 0)
    ClaimEventValidator.const_set(:MAXIMUM_CLAIM_COUNT_PER_DAY, 5)
    type_script_args = "0x94bbc8327e16d195de87815c391e7b9131e80419c51a405a0b21227c6ee05129"
    pk160 = "0x69b7667edbe08cf19413102fcadc53c67e34fb71"
    request_body = { data: { id: 1, type: "claim_event", attributes: {
        request_uuid: type_script_args, request_type: 1, pk160: pk160, acp_type: "new"
    } } }.to_json
    error_object = Api::V1::ApiError::ExceedsDailyQuotaLimitError.new
    response_json = ApiErrorSerializer.new([error_object], message: error_object.title).serialized_json
    timestamp = Time.now.utc.strftime("%Y%m%dT%H%M%SZ")
    request = mock
    body = StringIO.new(request_body)
    headers = { "x-ckbfs-date": timestamp, host: "domain.com" }.stringify_keys
    request.expects(:headers).returns(headers).at_least_once
    request.expects(:query_string).returns("").at_least_once
    request.expects(:method).returns("POST").at_least_once
    request.expects(:body).returns(body).at_least_once

    valid_post api_v1_claim_events_url, params: request_body, headers: { "x-ckbfs-date": timestamp, "authorization": authorization(request, timestamp, product1) }

    assert_equal response_json, response.body
  end

  test "should return error object when request type is invalid" do
    product = create(:product, quota_config: { "h24_quota": 4, "h24_quota_per_request_type": 2 })
    product1 = create(:product, name: "KFC1", quota_config: { "h24_quota": 2, "h24_quota_per_request_type": 1 })
    create_list(:claim_event, 2, product: product, request_type: 0)
    create_list(:claim_event, 2, product: product, request_type: 1)
    create(:claim_event, product: product1, request_type: 0)
    ClaimEventValidator.const_set(:MAXIMUM_CLAIM_COUNT_PER_DAY, 5)
    type_script_args = "0x94bbc8327e16d195de87815c391e7b9131e80419c51a405a0b21227c6ee05129"
    pk160 = "0x69b7667edbe08cf19413102fcadc53c67e34fb71"
    request_body = { data: { id: 1, type: "claim_event", attributes: {
        request_uuid: type_script_args, request_type: 100, pk160: pk160
    } } }.to_json
    error_object = Api::V1::ApiError::RequestTypeInvalidError.new
    response_json = ApiErrorSerializer.new([error_object], message: error_object.title).serialized_json
    timestamp = Time.now.utc.strftime("%Y%m%dT%H%M%SZ")
    request = mock
    body = StringIO.new(request_body)
    headers = { "x-ckbfs-date": timestamp, host: "domain.com" }.stringify_keys
    request.expects(:headers).returns(headers).at_least_once
    request.expects(:query_string).returns("").at_least_once
    request.expects(:method).returns("POST").at_least_once
    request.expects(:body).returns(body).at_least_once

    valid_post api_v1_claim_events_url, params: request_body, headers: { "x-ckbfs-date": timestamp, "authorization": authorization(request, timestamp, product1) }

    assert_equal response_json, response.body
  end

  test "should return error object when request_uuid is not a valid hex string" do
    product = create(:product, quota_config: { "h24_quota": 4, "h24_quota_per_request_type": 2 })
    type_script_args = "123144"
    pk160 = "0x69b7667edbe08cf19413102fcadc53c67e34fb71"
    request_body = { data: { id: 1, type: "claim_event", attributes: {
        request_uuid: type_script_args, request_type: 0, pk160: pk160, acp_type: "new"
    } } }.to_json
    timestamp = Time.now.utc.strftime("%Y%m%dT%H%M%SZ")
    request = mock
    body = StringIO.new(request_body)
    headers = { "x-ckbfs-date": timestamp, host: "domain.com" }.stringify_keys
    request.expects(:headers).returns(headers).at_least_once
    request.expects(:query_string).returns("").at_least_once
    request.expects(:method).returns("POST").at_least_once
    request.expects(:body).returns(body).at_least_once

    valid_post api_v1_claim_events_url, params: request_body, headers: { "x-ckbfs-date": timestamp, "authorization": authorization(request, timestamp, product) }

    error_object = Api::V1::ApiError::RequestUUIDInvalidError.new
    expected_response = ApiErrorSerializer.new([error_object], message: error_object.title).serialized_json

    assert_equal expected_response, response.body
  end

  test "should return error object when pk160 is not a valid hex string" do
    product = create(:product, quota_config: { "h24_quota": 4, "h24_quota_per_request_type": 2 })
    type_script_args = "0x94bbc8327e16d195de87815c391e7b9131e80419c51a405a0b21227c6ee05129"
    pk160 = "555"
    request_body = { data: { id: 1, type: "claim_event", attributes: {
        request_uuid: type_script_args, request_type: 0, pk160: pk160
    } } }.to_json
    timestamp = Time.now.utc.strftime("%Y%m%dT%H%M%SZ")
    request = mock
    body = StringIO.new(request_body)
    headers = { "x-ckbfs-date": timestamp, host: "domain.com" }.stringify_keys
    request.expects(:headers).returns(headers).at_least_once
    request.expects(:query_string).returns("").at_least_once
    request.expects(:method).returns("POST").at_least_once
    request.expects(:body).returns(body).at_least_once

    valid_post api_v1_claim_events_url, params: request_body, headers: { "x-ckbfs-date": timestamp, "authorization": authorization(request, timestamp, product) }

    error_object = Api::V1::ApiError::Pk160InvalidError.new
    expected_response = ApiErrorSerializer.new([error_object], message: error_object.title).serialized_json

    assert_equal expected_response, response.body
  end

  test "should return error object when pk160 bytesize is less than min acp args bytesize" do
    product = create(:product, quota_config: { "h24_quota": 4, "h24_quota_per_request_type": 2 })
    type_script_args = "0x94bbc8327e16d195de87815c391e7b9131e80419c51a405a0b21227c6ee05129"
    pk160 = "0x0124"
    request_body = { data: { id: 1, type: "claim_event", attributes: {
        request_uuid: type_script_args, request_type: 0, pk160: pk160
    } } }.to_json
    timestamp = Time.now.utc.strftime("%Y%m%dT%H%M%SZ")
    request = mock
    body = StringIO.new(request_body)
    headers = { "x-ckbfs-date": timestamp, host: "domain.com" }.stringify_keys
    request.expects(:headers).returns(headers).at_least_once
    request.expects(:query_string).returns("").at_least_once
    request.expects(:method).returns("POST").at_least_once
    request.expects(:body).returns(body).at_least_once

    valid_post api_v1_claim_events_url, params: request_body, headers: { "x-ckbfs-date": timestamp, "authorization": authorization(request, timestamp, product) }

    error_object = Api::V1::ApiError::Pk160InvalidError.new
    expected_response = ApiErrorSerializer.new([error_object], message: error_object.title).serialized_json

    assert_equal expected_response, response.body
  end

  test "should return error object when pk160 bytesize is more than max acp args bytesize" do
    product = create(:product, quota_config: { "h24_quota": 4, "h24_quota_per_request_type": 2 })
    type_script_args = "0x94bbc8327e16d195de87815c391e7b9131e80419c51a405a0b21227c6ee05129"
    pk160 = "0x#{SecureRandom.hex(23)}"
    request_body = { data: { id: 1, type: "claim_event", attributes: {
        request_uuid: type_script_args, request_type: 0, pk160: pk160
    } } }.to_json
    timestamp = Time.now.utc.strftime("%Y%m%dT%H%M%SZ")
    request = mock
    body = StringIO.new(request_body)
    headers = { "x-ckbfs-date": timestamp, host: "domain.com" }.stringify_keys
    request.expects(:headers).returns(headers).at_least_once
    request.expects(:query_string).returns("").at_least_once
    request.expects(:method).returns("POST").at_least_once
    request.expects(:body).returns(body).at_least_once

    valid_post api_v1_claim_events_url, params: request_body, headers: { "x-ckbfs-date": timestamp, "authorization": authorization(request, timestamp, product) }

    error_object = Api::V1::ApiError::Pk160InvalidError.new
    expected_response = ApiErrorSerializer.new([error_object], message: error_object.title).serialized_json

    assert_equal expected_response, response.body
  end

  test "should get uuid when one pk160 was already claimed but for another uuid" do
    product = create(:product, quota_config: { "h24_quota": 4, "h24_quota_per_request_type": 2 })
    type_script_args = "0x94bbc8327e16d195de87815c391e7b9131e80419c51a405a0b21227c6ee05129"
    pk160 = "0x69b7667edbe08cf19413102fcadc53c67e34fb71"
    request_body = { data: { id: 1, type: "claim_event", attributes: {
        request_uuid: type_script_args, request_type: 0, pk160: pk160, acp_type: "new"
    } } }.to_json
    create(:claim_event, product: product, pk160: pk160, request_uuid: "0x6e842ebb7d7fca88495c5f2edb05070198f6f8c798d7b8f1a48226f8f060c693")
    timestamp = Time.now.utc.strftime("%Y%m%dT%H%M%SZ")
    request = mock
    body = StringIO.new(request_body)
    headers = { "x-ckbfs-date": timestamp, host: "domain.com" }.stringify_keys
    request.expects(:headers).returns(headers).at_least_once
    request.expects(:query_string).returns("").at_least_once
    request.expects(:method).returns("POST").at_least_once
    request.expects(:body).returns(body).at_least_once

    valid_post api_v1_claim_events_url, params: request_body, headers: { "x-ckbfs-date": timestamp, "authorization": authorization(request, timestamp, product) }

    expected_response = ClaimEventSerializer.new(ClaimEvent.find_by(request_uuid: type_script_args)).serialized_json

    assert_equal expected_response, response.body
  end

  test "should get return error object when one pk160 was already claimed" do
    product = create(:product, quota_config: { "h24_quota": 4, "h24_quota_per_request_type": 2 })
    type_script_args = "0x94bbc8327e16d195de87815c391e7b9131e80419c51a405a0b21227c6ee05129"
    pk160 = "0x69b7667edbe08cf19413102fcadc53c67e34fb71"
    request_body = { data: { id: 1, type: "claim_event", attributes: {
        request_uuid: type_script_args, request_type: 0, pk160: pk160
    } } }.to_json
    create(:claim_event, product: product, pk160: pk160, request_uuid: type_script_args)
    timestamp = Time.now.utc.strftime("%Y%m%dT%H%M%SZ")
    request = mock
    body = StringIO.new(request_body)
    headers = { "x-ckbfs-date": timestamp, host: "domain.com" }.stringify_keys
    request.expects(:headers).returns(headers).at_least_once
    request.expects(:query_string).returns("").at_least_once
    request.expects(:method).returns("POST").at_least_once
    request.expects(:body).returns(body).at_least_once

    valid_post api_v1_claim_events_url, params: request_body, headers: { "x-ckbfs-date": timestamp, "authorization": authorization(request, timestamp, product) }

    error_object = Api::V1::ApiError::Pk160AlreadyClaimedError.new
    expected_response = ApiErrorSerializer.new([error_object], message: error_object.title).serialized_json

    assert_equal expected_response, response.body
  end

  test "should get uuid after claim event created" do
    product = create(:product, quota_config: { "h24_quota": 4, "h24_quota_per_request_type": 2 })
    type_script_args = "0x94bbc8327e16d195de87815c391e7b9131e80419c51a405a0b21227c6ee05129"
    pk160 = "0x69b7667edbe08cf19413102fcadc53c67e34fb71"
    request_body = { data: { id: 1, type: "claim_event", attributes: {
        request_uuid: type_script_args, request_type: 0, pk160: pk160, acp_type: "new"
    } } }.to_json
    timestamp = Time.now.utc.strftime("%Y%m%dT%H%M%SZ")
    request = mock
    body = StringIO.new(request_body)
    headers = { "x-ckbfs-date": timestamp, host: "domain.com" }.stringify_keys
    request.expects(:headers).returns(headers).at_least_once
    request.expects(:query_string).returns("").at_least_once
    request.expects(:method).returns("POST").at_least_once
    request.expects(:body).returns(body).at_least_once

    valid_post api_v1_claim_events_url, params: request_body, headers: { "x-ckbfs-date": timestamp, "authorization": authorization(request, timestamp, product) }

    expected_response = ClaimEventSerializer.new(ClaimEvent.last).serialized_json

    assert_equal expected_response, response.body
  end

  test "should set right content type when call show" do
    claim_event = create(:claim_event)

    valid_get api_v1_claim_event_url(claim_event)

    assert_equal "application/vnd.api+json", response.media_type
  end

  test "should respond with 415 Unsupported Media Type when call show and Content-Type is wrong" do
    claim_event = create(:claim_event)

    get api_v1_claim_event_url(claim_event), headers: { "Content-Type": "text/plain" }

    assert_equal 415, response.status
  end

  test "should not respond with 415 when not set content type" do
    claim_event = create(:claim_event)

    get api_v1_claim_event_url(claim_event), headers: { "Accept": "application/vnd.api+json" }

    assert_not_equal 415, response.status
  end

  test "should respond with error object when call show and Content-Type is wrong" do
    claim_event = create(:claim_event)
    error_object = Api::V1::ApiError::ContentTypeInvalidError.new
    response_json = ApiErrorSerializer.new([error_object], message: error_object.title).serialized_json

    get api_v1_claim_event_url(claim_event), headers: { "Content-Type": "text/plain" }

    assert_equal response_json, response.body
  end

  test "should respond with 406 Not Acceptable when call show and Accept is wrong" do
    claim_event = create(:claim_event)

    get api_v1_claim_event_url(claim_event), headers: { "Content-Type": "application/vnd.api+json", "Accept": "application/json" }

    assert_equal 406, response.status
  end

  test "should respond with error object when call show and Accept is wrong" do
    claim_event = create(:claim_event)
    error_object = Api::V1::ApiError::AcceptInvalidError.new
    response_json = ApiErrorSerializer.new([error_object], message: error_object.title).serialized_json

    get api_v1_claim_event_url(claim_event), headers: { "Content-Type": "application/vnd.api+json", "Accept": "application/json" }

    assert_equal response_json, response.body
  end

  test "should return error object when no record found by given id" do
    product = create(:product, quota_config: { "h24_quota": 4, "h24_quota_per_request_type": 2 })
    timestamp = Time.now.utc.strftime("%Y%m%dT%H%M%SZ")
    request = mock
    body = StringIO.new
    headers = { "x-ckbfs-date": timestamp, host: "domain.com" }.stringify_keys
    request.expects(:headers).returns(headers).at_least_once
    request.expects(:query_string).returns("").at_least_once
    request.expects(:method).returns("GET").at_least_once
    request.expects(:body).returns(body).at_least_once
    error_object = Api::V1::ApiError::ClaimEventNotFoundError.new
    response_json = ApiErrorSerializer.new([error_object], message: error_object.title).serialized_json

    valid_get api_v1_claim_event_url("abc"), headers: { "x-ckbfs-date": timestamp, "authorization": authorization(request, timestamp, product) }

    assert_equal response_json, response.body
  end

  test "should return respond with error object when acp type is old" do
    product = create(:product, quota_config: { "h24_quota": 4, "h24_quota_per_request_type": 2 })
    type_script_args = "0x94bbc8327e16d195de87815c391e7b9131e80419c51a405a0b21227c6ee05129"
    pk160 = "0x69b7667edbe08cf19413102fcadc53c67e34fb71"
    request_body = { data: { id: 1, type: "claim_event", attributes: {
      request_uuid: type_script_args, request_type: 0, pk160: pk160, acp_type: "old"
    } } }.to_json
    timestamp = Time.now.utc.strftime("%Y%m%dT%H%M%SZ")
    request = mock
    body = StringIO.new(request_body)
    headers = { "x-ckbfs-date": timestamp, host: "domain.com" }.stringify_keys
    request.expects(:headers).returns(headers).at_least_once
    request.expects(:query_string).returns("").at_least_once
    request.expects(:method).returns("POST").at_least_once
    request.expects(:body).returns(body).at_least_once

    valid_post api_v1_claim_events_url, params: request_body, headers: { "x-ckbfs-date": timestamp, "authorization": authorization(request, timestamp, product) }
    error_object = Api::V1::ApiError::AcpTypeError.new
    response_json = ApiErrorSerializer.new([error_object], message: error_object.title).serialized_json

    assert_equal response_json, response.body
  end
end
