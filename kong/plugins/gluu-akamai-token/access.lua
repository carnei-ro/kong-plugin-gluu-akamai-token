local plugin_name      = ({...})[1]:match("^kong%.plugins%.([^%.]+)")
local akamai_edge_auth = require("kong.plugins." .. plugin_name .. ".akamai_edge_auth")
local gluu             = require("kong.plugins." .. plugin_name .. ".gluu")
local state_utils      = require("kong.plugins." .. plugin_name .. ".state_utils")

local kong         = kong
local cjson        = require("cjson.safe").new()
local table_concat = table.concat

cjson.decode_array_with_array_mt(true)

local ngx_time = ngx.time

local _M = {}

function _M.execute(conf)
  local state = kong.request.get_query_arg("state")
  local code = kong.request.get_query_arg("code")
  if ((not state) or (not code)) then
    kong.response.exit(400, {["err"] = "Missing query param 'state' and/or 'code'"})
  end

  local decoded_state, err, state_version = state_utils:validate_and_decode_state(state, conf['token_key'], conf['state_algorithm'])
  if err then
    kong.response.exit(400, {["err"] = err })
  end

  local parsed_state, err = state_utils:parse_state(state_version, decoded_state)
  if err then
    kong.response.exit(400, {["err"] = err })
  end

  local token_tbl, err = gluu:request_access_token(
    (conf['gluu_url'] .. conf['gluu_token_endpoint']),
    code,
    conf['client_id'],
    conf['client_secret'],
    kong.request.get_scheme() .. '://' .. kong.request.get_host() .. kong.request.get_path(),
    conf['ssl_verify']
  )
  if err then
    kong.response.exit(400, {["err"] = err })
  end

  local profile, err = gluu:request_profile(
    (conf['gluu_url'] .. conf['gluu_userinfo_endpoint']),
    token_tbl["access_token"],
    token_tbl["id_token"],
    conf['ssl_verify']
  )
  if err then
    kong.response.exit(400, {["err"] = err })
  end

  local cookie, err = akamai_edge_auth:sign_token(
    (ngx_time() + parsed_state['ttl']),
    table_concat({'/*'}, '!'),
    '~',
    conf['token_key'],
    conf['token_algorithm'],
    akamai_edge_auth:concat_dict_table({
      ["sub"]    = profile["email"],
      ["name"]   = profile["name"],
      ["roles"]  = profile["roles"] and cjson.encode(profile["roles"]) or nil,
      ["domain"] = profile["email"]:match("[^@]+@(.+)"),
      ["iss"]    = parsed_state["issuer"],
    }, '&')
  )
  if err then
    kong.response.exit(400, {["err"] = err })
  end

  local cookie_tail = ";version=1;path=/;secure;Max-Age=" .. (parsed_state['ttl'] - 5)
  if parsed_state['http_only'] then
    cookie_tail = cookie_tail .. ";httponly"
  end

  return parsed_state['redirect'], (parsed_state['cookie_name'] .. '=' .. cookie .. cookie_tail)

end

return _M
