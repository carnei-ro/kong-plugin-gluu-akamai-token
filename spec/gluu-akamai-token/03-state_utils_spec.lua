require "spec.helpers"

local PLUGIN_NAME = "gluu-akamai-token"

describe("[" .. PLUGIN_NAME .. "] state_utils", function()

  local state_utils = require("kong.plugins." .. PLUGIN_NAME .. ".state_utils")
  local alg = "sha256"
  local key = "b79143bf58085a98ba4056ede3b506db0d791de8a7802b1fe2cfe78509a06f9d"

  describe("validate_and_decode_state", function()
    it("validates state v1, edgetoken, 86400, not httponly", function()
      local state = 'eyJkIjoidjE7ZWRnZXRva2VuOzg2NDAwO2ZhbHNlO3Rlc3QxLmNvbTtodHRwOi8vdGVzdDEuY29tL2luZGV4Lmh0bWwiLCJ2IjoidjEiLCJlIjoiYmhIRFBEcGwzKzFQUmZuWUY3N0tmbDByN0l0WjBWU0hkeFBOd1BMMmNPTT0ifQ=='
      local state_string, err, state_version = state_utils:validate_and_decode_state(state, key, alg)
      
      assert.is_nil(err)
      assert.is_truthy(state_string)
      assert.is_truthy(state_version)
      assert.equal(state_string, "v1;edgetoken;86400;false;test1.com;http://test1.com/index.html")
      assert.equal(state_version, "v1")
    end)

    it("validates state v1, edgetoken, 86400, httponly", function()
      local state = 'eyJkIjoidjE7ZWRnZXRva2VuOzg2NDAwO3RydWU7dGVzdDEuY29tO2h0dHA6Ly90ZXN0MS5jb20vaW5kZXguaHRtbCIsInYiOiJ2MSIsImUiOiJvcm5Jb2JGMXlWM0JKNzl2QTVuTTZKTlNYVU5DT0RMUE5KYlRRcllxRUY4PSJ9'
      local state_string, err, state_version = state_utils:validate_and_decode_state(state, key, alg)
      
      assert.is_nil(err)
      assert.is_truthy(state_string)
      assert.is_truthy(state_version)
      assert.equal(state_string, "v1;edgetoken;86400;true;test1.com;http://test1.com/index.html")
      assert.equal(state_version, "v1")
    end)

    it("validates state v2 full", function()
      local state = 'eyJkIjoidjI7ZWRnZXRva2VuOzg2NDAwO3RydWU7dHJ1ZTtha2FtYWlfdG9rZW47LmJhci5jb207LztTdHJpY3Q7aHR0cDovL2Zvby5iYXIuY29tL2luZGV4Lmh0bWwiLCJ2IjoidjIiLCJlIjoiVUhaZTFEOU91S0hQbHpmQ1BxOVF6aVArSXduWkdLTXd0dEFod0hkdkxRZz0ifQ=='
      local state_string, err, state_version = state_utils:validate_and_decode_state(state, key, alg)

      assert.is_nil(err)
      assert.is_truthy(state_string)
      assert.is_truthy(state_version)
      assert.equal(state_string, "v2;edgetoken;86400;true;true;akamai_token;.bar.com;/;Strict;http://foo.bar.com/index.html")
      assert.equal(state_version, "v2")
    end)

    it("validates state v2 missing fields", function()
      local state = 'eyJkIjoidjI7ZWRnZXRva2VuOzg2NDAwO3RydWU7dHJ1ZTtha2FtYWlfdG9rZW47Ozs7aHR0cDovL2Zvby5iYXIuY29tL2luZGV4Lmh0bWwiLCJ2IjoidjIiLCJlIjoiWkNqNmJjTTRuUHM2Y0szOWRWUWx5TXRXdVJwcHpoU0RvS1lLQndHQ2YzZz0ifQ=='
      local state_string, err, state_version = state_utils:validate_and_decode_state(state, key, alg)

      assert.is_nil(err)
      assert.is_truthy(state_string)
      assert.is_truthy(state_version)
      assert.equal(state_string, "v2;edgetoken;86400;true;true;akamai_token;;;;http://foo.bar.com/index.html")
      assert.equal(state_version, "v2")
    end)

    it("validates wrong signature", function()
      local state = 'eyJkIjoidjE7ZWRnZXRva2VuOzg2NDAwO3RydWU7dGVzdDEuY29tO2h0dHA6Ly90ZXN0MS5jb20vaW5kZXguaHRtbCIsInYiOiJ2MSIsImUiOiJ3cm9uZyBzaWduYXR1cmUgaGVyZSJ9'
      local state_string, err, state_version = state_utils:validate_and_decode_state(state, key, alg)
      
      assert.is_truthy(err)
      assert.is_nil(state_string)
      assert.is_nil(state_version)
      assert.equal(err, "State signature does not match.\nState Signature: wrong signature here, Calculated Signature: ornIobF1yV3BJ79vA5nM6JNSXUNCODLPNJbTQrYqEF8=")
    end)
  end)

  describe("parse_state", function()
    it("truthy v1", function()
      local state_version = "v1"
      local state_string = "v1;edgetoken;86400;true;test1.com;http://test1.com/index.html"
      local state_tbl, err = state_utils:parse_state(state_version, state_string)
      
      assert.is_nil(err)
      assert.is_truthy(state_tbl)
      assert.equal(state_tbl["cookie_name"], "edgetoken")
      assert.equal(state_tbl["ttl"]        , 86400)
      assert.equal(state_tbl["http_only"]  , true)
      assert.equal(state_tbl["issuer"]     , "test1.com")
      assert.equal(state_tbl["redirect"]   , "http://test1.com/index.html")
    end)

    it("truthy v2 - full", function()
      local state_version = "v2"
      local state_string = "v2;edgetoken;86400;true;true;akamai_token;.bar.com;/;Strict;http://foo.bar.com/index.html"
      local state_tbl, err = state_utils:parse_state(state_version, state_string)

      assert.is_nil(err)
      assert.is_truthy(state_tbl)
      assert.equal(state_tbl["cookie_name"], "edgetoken")
      assert.equal(state_tbl["ttl"]        , 86400)
      assert.equal(state_tbl["http_only"]  , true)
      assert.equal(state_tbl["secure"]     , true)
      assert.equal(state_tbl["issuer"]     , "akamai_token")
      assert.equal(state_tbl["domain"]     , ".bar.com")
      assert.equal(state_tbl["path"]       , "/")
      assert.equal(state_tbl["same_site"]  , "Strict")
      assert.equal(state_tbl["redirect"]   , "http://foo.bar.com/index.html")
    end)

    it("truthy v2 - missing fields", function()
      local state_version = "v2"
      local state_string = "v2;edgetoken;86400;true;true;akamai_token;;;;http://foo.bar.com/index.html"
      local state_tbl, err = state_utils:parse_state(state_version, state_string)

      assert.is_nil(err)
      assert.is_truthy(state_tbl)
      assert.equal(state_tbl["cookie_name"], "edgetoken")
      assert.equal(state_tbl["ttl"]        , 86400)
      assert.equal(state_tbl["http_only"]  , true)
      assert.equal(state_tbl["secure"]     , true)
      assert.equal(state_tbl["issuer"]     , "akamai_token")
      assert.equal(state_tbl["domain"]     , '')
      assert.equal(state_tbl["path"]       , '')
      assert.equal(state_tbl["same_site"]  , '')
      assert.equal(state_tbl["redirect"]   , "http://foo.bar.com/index.html")
    end)

    it("parser version not implemented", function()
      local state_version = "v3"
      local state_string = "v1;edgetoken;86400;true;test1.com;http://test1.com/index.html"
      local state_tbl, err = state_utils:parse_state(state_version, state_string)

      assert.is_nil(state_tbl)
      assert.is_truthy(err)
      assert.equal(err, "Parser for State version " .. state_version .. " not implemented yet.")
    end)

    it("fail when spoofing state version", function()
      local state_version = "v1"
      local state_string = "v2;edgetoken;86400;true;test1.com;http://test1.com/index.html"
      local state_tbl, err = state_utils:parse_state(state_version, state_string)

      assert.is_nil(state_tbl)
      assert.is_truthy(err)
      assert.equal(err, "State version does not match state at state string.")
    end)
  end)

end)
