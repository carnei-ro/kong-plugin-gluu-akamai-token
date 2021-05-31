local openssl_hmac = require "resty.openssl.hmac"
local pairs = pairs
local table_insert = table.insert
local table_concat = table.concat
local string_gsub = string.gsub
local string_char = string.char
local string_lower = string.lower
local string_format = string.format
local string_byte = string.byte
local tonumber = tonumber

local _M = {}

function _M:concat_dict_table(tbl, delimiter)
  local r = {}
  local d = delimiter and delimiter or ","
  for k, v in pairs(tbl) do
    table_insert(r, table_concat{k, '=', v})
  end
  return table_concat(r, d)
end

local function hex2ascii(s)
  local r = string_gsub(s,"(.)(.)",function (x,y) local c = (x..y) return string_char(tonumber(c, 16)) end)
  return r
end

local function bin2hex(s)
    local s = string_gsub(s,"(.)",function (x) return string_lower(string_format("%02X",string_byte(x))) end)
    return s
end

function _M:sign_token(exp, acl, field_delimiter, key, alg, data)
  local to_sign_string = _M:concat_dict_table({
    ["exp"] = exp,
    ["acl"] = acl,
    ["data"] = data
  }, field_delimiter)
  
  local signature, err = openssl_hmac.new(hex2ascii(key), alg):final(to_sign_string)
  if err then
    return nil, err
  end
  
  local hex_signature = bin2hex(signature)
  
  local r = table_concat({to_sign_string, '~hmac=', hex_signature})

  return r, nil
end

return _M
