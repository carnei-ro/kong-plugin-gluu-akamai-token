local plugin_name = ({...})[1]:match("^kong%.plugins%.([^%.]+)")
local access = require("kong.plugins." .. plugin_name .. ".access")

local kong = kong

local plugin = {
  PRIORITY = 1000,
  VERSION = "0.2.0",
}

function plugin:access(plugin_conf)
  local location, cookie_string = access.execute(plugin_conf)

  return kong.response.exit(302, {}, {
    ["Location"]   = location,
    ["Set-Cookie"] = cookie_string
  })
end

return plugin
