local openssl_hmac = require("resty.openssl.hmac")
local cjson        = require("cjson.safe").new()
local b64_encode   = ngx.encode_base64

cjson.decode_array_with_array_mt(true)

local alg = "sha256"
local key = "b79143bf58085a98ba4056ede3b506db0d791de8a7802b1fe2cfe78509a06f9d"

local function generate_state_str(state_version, state_str, key, alg)
    local signature, _ = openssl_hmac.new(key, alg):final(state_str)
    local sig = b64_encode(signature)
    return '{"d":"'..state_str..'","v":"'..state_version..'","e":"'..sig..'"}'
end

print(b64_encode(
    generate_state_str("v2", "v2;edgetoken;86400;true;true;akamai_token;.bar.com;/;Strict;http://foo.bar.com/index.html", key, alg) 
))

print(b64_encode(
    generate_state_str("v2", "v2;edgetoken;86400;true;true;akamai_token;;;;http://foo.bar.com/index.html", key, alg) 
))

print(b64_encode(
    generate_state_str("v2", "v2;my_token;43200;false;false;akamai_token;.bar.com;/api;Lax;http://foo.bar.com/index.html", key, alg) 
))
