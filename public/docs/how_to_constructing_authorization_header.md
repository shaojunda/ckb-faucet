## How to constructing authorization header

The authorization header contain the signature for the request. Generating the signature is a process best understood in 5 distinct steps:
1. [Canonical request](#step-1--build-canonical-request)
2. [String to sign](#step-2--string-to-sign)
3. [Generate user's signing key](#step-3--generate-user-s-signing-key)
4. [Calculate signature](#step-4--calculate-signature)
5. [Build the authorization header](#step-5--build-the-authorization-header)

### Step 1: Build Canonical request
Canonical request's blueprint looks like this:

```
<HTTPMethod>\n
<CanonicalURI>\n
<CanonicalQueryString>\n
<CanonicalHeaders>\n
<SignedHeaders>\n
<HashedPayload>
```

For `GET /claim_events/{id}`, the result is as follows:

```
GET
faucet-priv-testnet-dev.nervos.tech

host:faucet-priv-testnet-dev.nervos.tech
x-ckbfs-content-sha256:e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855
x-ckbfs-date:20200616T174446Z

host;x-ckbfs-content-sha256;x-ckbfs-date
e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
```

Notes:
  * in this case, `<CanonicalQueryString>` is an empty string. Note however that the line must not be omitted and the newline is required.
  * in this case, `<CanonicalHeaders>` only required headers are `host`, `x-ckbfs-content-sha256` and `x-ckbfs-date`. The names of the headers are lowercase and whitespace is stripped, sorted by character code, one per line.
  * `<SignedHeaders>` is a semicolon-separated list of the headers. We just repeat the ones we used for `<CanonicalHeaders>`. 
  * `<HashedPayload>` is the SHA256 checksum of the request payload. Since we carry no payload in this request, we append the SHA256 hash of an empty string.

### Step 2: String to sign

The required format of this string looks like this:
```
CKBFS1-HMAC-SHA256\n
<Timestamp>\n
<CredentialScope>\n
<CanonicalRequestHash>
```
For `GET /claim_events/{id}`:
```
CKBFS1-HMAC-SHA256
20200616T174446Z
20200616/faucet/ckbfs1_request
499160e9ac38e56989e215bbdb2a62d61b251e9c492f6549a62c4cf9f09955d9"
```

Notes:
  * `CKBFS1-HMAC-SHA256` is a constant string which needs to be placed in the first line. It specifies the hash algorithm used for request signing.
  * `<Timestamp>` is the current UTC time in ISO 8601 basic format.
  * `<CredentialScope>` binds the request to a certain date and service. It must be in the format: `<yyyyMMdd>/<Service>/ckbfs1_request`, where `ckbfs1_request` is a constant string.
  * `<CanonicalRequestHash>` is a hexadecimal representation of the SHA256 hash of our canonical request - the string from Step 1.
    
### Step 3: Generate user’s signing key

We have the string to sign, now we need the key which we’ll use to sign it. The signing key is derived from the user’s secret access key, through a four-step HMAC-SHA256 hashing process.
This process is similar to [aws processing](https://docs.aws.amazon.com/general/latest/gr/signature-v4-examples.html) it has many examples in a number of programming languages.
deriving a singing key using Ruby is
```ruby
def signing_key
  k_date = OpenSSL::HMAC.digest("sha256", "ckbfs1" + secret_access_key, date)
  k_service = OpenSSL::HMAC.digest("sha256", k_date, SERVICE_NAME)
  kSigning = OpenSSL::HMAC.digest("sha256", k_service, TERMINATION_STR)

  kSigning
end
```

### Step 4: Calculate signature
We have the string to sign and we have the signing key - now we need one final HMAC-SHA256 calculation to obtain the signature.
`OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new("sha256"), signing_key, string_to_sign)`

### Step 5: Build the authorization header
The calculated signature needs to be placed in the authorization header and included in the HTTP request. The format of the header is as follows:
`authorization: <Algorithm> Credential=<Access Key ID/CredentialScope>, SignedHeaders=<SignedHeaders>, Signature=<Signature>`

We’ve already seen most of the values in previous steps. The only addition is the <Access Key ID>, where we place faucet access key ID. In our example, the complete header looks like this:
`CKBFS1-HMAC-SHA256 Credential=pGUDimqkf1KXrabnz7uX9DEJ/20200616/faucet/ckbfs1_request, SignedHeaders=host;x-ckbfs-content-sha256;x-ckbfs-date, Signature=cc79989721399bbffd3657d3e053328c35d63d3fd95f200bd190b41d05c00830`

### Final step: Perform the request

[Ruby sample code](claim_example.rb)
