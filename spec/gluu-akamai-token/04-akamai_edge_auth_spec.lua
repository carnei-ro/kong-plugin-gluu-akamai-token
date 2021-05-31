require "spec.helpers"

local PLUGIN_NAME = "gluu-akamai-token"
local cjson        = require("cjson.safe").new()
local table_concat = table.concat

cjson.decode_array_with_array_mt(true)

describe("[" .. PLUGIN_NAME .. "] akamai_edge_auth", function()

  local akamai_edge_auth = require("kong.plugins." .. PLUGIN_NAME .. ".akamai_edge_auth")
  local alg = "sha256"
  local key = "b79143bf58085a98ba4056ede3b506db0d791de8a7802b1fe2cfe78509a06f9d"

  describe("concat_dict_table", function()
    it("kv table", function()
      local tbl = {
        ["key1"] = "value1",
        ["key2"] = "value2",
        ["key3"] = "value3",
      }
      local delimiter = '~'
      local s = akamai_edge_auth:concat_dict_table(tbl, delimiter)
      
      assert.is_truthy(s)
      assert.equal(s, "key1=value1~key2=value2~key3=value3")
    end)
  
    it("kv table2", function()
      local tbl = {
              ["sub"]    = "leandro@carnei.ro",
              ["name"]   = "Leandro Carneiro",
              ["roles"]  = '["Admin"]',
              ["domain"] = "carnei.ro",
              ["iss"]    = "kong",
            }
      local delimiter = '&'
      local s = akamai_edge_auth:concat_dict_table(tbl, delimiter)
      
      assert.is_truthy(s)
      assert.equal(s, 'roles=["Admin"]&sub=leandro@carnei.ro&iss=kong&name=Leandro Carneiro&domain=carnei.ro')
    end)
  
    it("array table", function()
      local tbl = {
              "GET",
              "POST",
              "DELETE",
              "HEAD",
              "PUT",
            }
      local delimiter = '!'
      local s = akamai_edge_auth:concat_dict_table(tbl, delimiter)
      
      assert.is_truthy(s)
      assert.equal(s, '1=GET!2=POST!3=DELETE!4=HEAD!5=PUT')
    end)

  end)

  describe("sign_token", function()
    it("truthy", function()
      local exp = 1622427898
      local acl = table_concat({'/get*','/post*'}, '!')
      local field_delimiter = "~"
      local data = akamai_edge_auth:concat_dict_table({
                                      ["sub"]    = "leandro@carnei.ro",
                                      ["name"]   = "Leandro Carneiro",
                                      ["roles"]  = cjson.encode({"Admin"}),
                                      ["domain"] = "carnei.ro",
                                      ["iss"]    = "kong",
                                    }, '&')

      local token, err = akamai_edge_auth:sign_token(exp, acl, field_delimiter, key, alg, data)
      assert.is_nil(err)
      assert.is_truthy(token)
      assert.equal(token, 'data=roles=["Admin"]&sub=leandro@carnei.ro&iss=kong&name=Leandro Carneiro&domain=carnei.ro~acl=/get*!/post*~exp=1622427898~hmac=d948eb2b9676ab769179a67450b48eb66d5ead02b76ea630243c088cf1d1ef10')
    end)
  end)

end)
