local http         = require("resty.http")
local cjson        = require("cjson.safe").new()
local encode_args  = ngx.encode_args

cjson.decode_array_with_array_mt(true)

local _M = {}

function _M:request_profile(userinfo_url, access_token, id_token, ssl_verify)
  local request = http.new()

  request:set_timeout(3000)

  local res, err = request:request_uri(userinfo_url .. "?" .. encode_args({
      authorization = id_token,
      access_token  = access_token
    }), {
    method = "GET",
    ssl_verify = ssl_verify,
  })
  if not res then
    return nil, "auth info request failed: " .. (err or "unknown reason")
  end

  if res.status ~= 200 then
    return nil, "received " .. res.status .. " from " .. userinfo_url
  end

  return cjson.decode(res.body)
end

function _M:request_access_token(token_url, code, client_id, client_secret, redirect_uri, ssl_verify)
  local request = http.new()

  request:set_timeout(3000)

  local res, err = request:request_uri(token_url, {
      method = "POST",
      body = encode_args({
        code          = code,
        client_id     = client_id,
        client_secret = client_secret,
        redirect_uri  = redirect_uri,
        grant_type    = "authorization_code",
      }),
      headers = {
        ["Content-type"] = "application/x-www-form-urlencoded"
      },
      ssl_verify = ssl_verify,
  })
  if not res then
    return nil, (err or "auth token request failed: " .. (err or "unknown reason"))
  end

  if res.status ~= 200 then
    return nil, "received " .. res.status .. " from ".. token_url .. ": " .. res.body
  end

  return cjson.decode(res.body)
end


return _M
