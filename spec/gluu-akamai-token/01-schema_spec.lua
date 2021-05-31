local PLUGIN_NAME = "gluu-akamai-token"

-- helper function to validate data against a schema
local validate do
  local validate_entity = require("spec.helpers").validate_plugin_config_schema
  local plugin_schema = require("kong.plugins."..PLUGIN_NAME..".schema")

  function validate(data)
    return validate_entity(data, plugin_schema)
  end
end


describe(PLUGIN_NAME .. ": (schema)", function()

  it("token key is 32 hex string", function()
    local ok, err = validate({
        token_key     = 'b79143bf58085a98ba4056ede3b506db0d791de8a7802b1fe2cfe78509a06f9d',
        client_id     = 'my-client-id',
        client_secret = 'my-client-secret',
        gluu_url      = 'http://127.0.0.1'
      })
    assert.is_nil(err)
    assert.is_truthy(ok)
  end)

  it("token key is 32 hex string - error (not hex)", function()
    local ok, err = validate({
        token_key     = 'jlPLOA2DrXnnGrETzjjHwhTcq9Qct2tCauk5h1E6X4kdKe1F4oM9FOWnrdFsFNvX',
        client_id     = 'my-client-id',
        client_secret = 'my-client-secret',
        gluu_url      = 'http://127.0.0.1'
      })
    assert.is_nil(ok)
    assert.is_truthy(err)
    assert.equal('token key must be 64 chars (openssl rand -hex 32)', err['config']['token_key'])
  end)

  it("token key is 32 hex string - error (not 64char)", function()
    local ok, err = validate({
        token_key     = 'b79143bf58085a98ba4056ede3b506db',
        client_id     = 'my-client-id',
        client_secret = 'my-client-secret',
        gluu_url      = 'http://127.0.0.1'
      })
    assert.is_nil(ok)
    assert.is_truthy(err)
    assert.equal('token key must be 64 chars (openssl rand -hex 32)', err['config']['token_key'])
  end)

end)
