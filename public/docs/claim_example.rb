# frozen_string_literal: true

require "net/http"
require "pry"
class ClaimEventExample
  attr_reader :base_uri, :access_key_id, :secret_access_key

  def initialize(access_key_id, secret_access_key)
    @access_key_id = access_key_id
    @secret_access_key = secret_access_key
    @base_uri = "https://faucet-priv-testnet-dev.nervos.tech/api/v1/claim_events"
  end
  def post(request_body)
    claim_event_uri = URI(base_uri)
    https = Net::HTTP.new(claim_event_uri.host, claim_event_uri.port)
    https.use_ssl = true
    request = Net::HTTP::Post.new(claim_event_uri.path)
    request["Accept"] = "application/vnd.api+json"
    request["Content-Type"] = "application/vnd.api+json"

    # prepare sign data
    request.body = request_body

    # generate request header
    # 1. x-ckbfs-date, UTC time in ISO 8601 basic format, eg: 20200611T130513Z
    # 2. host request host
    # 3. authorization

    timestamp = Time.now.utc.strftime("%Y%m%dT%H%M%SZ")
    request["x-ckbfs-date"] = timestamp
    request["host"] = claim_event_uri.host

    signer = Signer.new(request, timestamp, secret_access_key)
    request["authorization"] = authorization(signer, access_key_id)

    # response = Net::HTTP.start(claim_event_uri.hostname, claim_event_uri.port) do |http|
    #   http.use_ssl = true
    #   http.request(request)
    # end
    #
    response = https.request(request)

    puts "http status: #{response.code}, response: #{JSON.parse(response.body)}"
  end

  def get(request_uuid)
    claim_event_uri = URI("#{base_uri}/#{request_uuid}")
    https = Net::HTTP.new(claim_event_uri.host, claim_event_uri.port)
    https.use_ssl = true
    request = Net::HTTP::Get.new(claim_event_uri)
    request["Accept"] = "application/vnd.api+json"

    # prepare sign data
    #
    # generate request body

    # generate request header
    # 1. x-ckbfs-date, UTC time in ISO 8601 basic format, eg: 20200611T130513Z
    # 2. host request host
    # 3. authorization

    timestamp = Time.now.utc.strftime("%Y%m%dT%H%M%SZ")
    request["x-ckbfs-date"] = timestamp
    request["host"] = claim_event_uri.host

    signer = Signer.new(request, timestamp, secret_access_key)
    request["authorization"] = authorization(signer, access_key_id)
    response = https.request(request)
    puts "http status: #{response.code}, response: #{JSON.parse(response.body)}"
  end

  def authorization(signer, access_key_id)
    [
        "#{Signer::ALGORITHM} Credential=#{credential(access_key_id, signer.credential_scope)}",
        "SignedHeaders=#{signer.signed_headers}",
        "Signature=#{signer.sign}"
    ].join(", ")
  end

  def credential(access_key_id, credential_scope)
    [
        access_key_id,
        credential_scope
    ].join("/")
  end
end

class Signer
  SERVICE_NAME = "faucet"
  ALGORITHM = "CKBFS1-HMAC-SHA256"
  TERMINATION_STR = "ckbfs1_request"

  attr_reader :request, :timestamp, :date, :secret_access_key

  def initialize(request, timestamp, secret_access_key)
    @request = request
    @timestamp = timestamp
    @date = timestamp[0, 8]
    @secret_access_key = secret_access_key
  end

  def sign
    OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new("sha256"), signing_key, string_to_sign)
  end

  def signed_headers
    %w(host x-ckbfs-content-sha256 x-ckbfs-date).sort.join(";")
  end

  def credential_scope
    [
        date,
        SERVICE_NAME,
        TERMINATION_STR
    ].join("/")
  end

  def signing_key
    k_date = OpenSSL::HMAC.digest("sha256", "ckbfs1" + secret_access_key, date)
    k_service = OpenSSL::HMAC.digest("sha256", k_date, SERVICE_NAME)
    kSigning = OpenSSL::HMAC.digest("sha256", k_service, TERMINATION_STR)

    kSigning
  end

  def string_to_sign
    [
        ALGORITHM,
        timestamp,
        credential_scope,
        sha256_hexdigest(canonical_request)
    ].join("\n")
  end

  def canonical_request
    http_method = request.method
    canonical_uri = request["host"]
    canonical_query_string = normalized_querystring("")
    payload = request.body || ""
    hashed_payload = sha256_hexdigest(payload)
    canonical_headers = %W[host:#{request["host"]} x-ckbfs-content-sha256:#{hashed_payload} x-ckbfs-date:#{timestamp}].join("\n") + "\n"
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

# replace your access key id, secret access key, type script args and pk160
access_key_id = "pGUDimqkf1KXrabnz7uX9DEJ"
secret_access_key = "euFzwfDD8m5wQRujh3touXgLhYudH5AySBPSSzC4"
type_script_args = "0x6e842ebb7d7fca88495c5f2edb05070198f6f8c798d7b8f1a48226f8f060c693"
pk160 = "0x0e7cd8e7f3524ef3419b94b3aae89cc019b41750"
request_body = {
    data: {
        type: "claim_event",
        attributes: {
            request_uuid: type_script_args, request_type: 0, pk160: pk160
        }
    }
}.to_json

# `post` method will get claim event UUID, use this UUID can get claim event status and tx status
# ClaimEventExample.new(access_key_id, secret_access_key).post(request_body)
# `get` method accepts claim event UUID and returns claim event status, tx_hash, and tx status
ClaimEventExample.new(access_key_id, secret_access_key).get("f6562cfe-3cb1-436d-864a-7d02b94ebe3d")