# frozen_string_literal: true

require "test_helper"

class Api::V1::ClaimEventsControllerTest < ActionDispatch::IntegrationTest
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
end
