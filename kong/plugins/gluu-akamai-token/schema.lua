local plugin_name = ({...})[1]:match("^kong%.plugins%.([^%.]+)")

local hex64char = '^[0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]$'

return {
  name = plugin_name,
  fields = {
    {
      config = {
        type = "record",
        fields = {
          {
            state_algorithm = {
              type = "string",
              default = "sha256",
              required = true,
              one_of = { "sha256", "sha1", "md5" },
            }
          },
          {
            token_key = {
              type = "string",
              required = true,
              match = hex64char,
              err = "token key must be 64 chars (openssl rand -hex 32)",
            }
          },
          {
            token_algorithm = {
              type = "string",
              default = "sha256",
              required = true,
              one_of = { "sha256", "sha1", "md5" },
            }
          },
          {
            ssl_verify = {
              type = "boolean",
              default = true,
              required = true,
            }
          },
          {
            client_id = {
              type = "string",
              required = true,
            }
          },
          {
            client_secret = {
              type = "string",
              required = true,
            }
          },
          {
            gluu_url = {
              type = "string",
              required = true,
            }
          },
          {
            gluu_token_endpoint = {
              default = "/oxauth/restv1/token",
              type = "string",
              required = true,
            }
          },
          {
            gluu_userinfo_endpoint = {
              default = "/oxauth/restv1/userinfo",
              type = "string",
              required = true,
            }
          },

        },
        entity_checks = {
          {
            conditional = {}
          },
        },
      },
    },
  },
}
