local helpers = require "spec.helpers"

local PLUGIN_NAME = "gluu-akamai-token"

for _, strategy in helpers.each_strategy() do
  describe(PLUGIN_NAME .. ": (access) [#" .. strategy .. "]", function()
    local client

    lazy_setup(function()

      local bp = helpers.get_db_utils(strategy, nil, { PLUGIN_NAME })

      local mock_token_endpoint = bp.routes:insert({
        paths = {"/oxauth/restv1/token"}
      })
      bp.plugins:insert {
        name = "request-termination",
        route = { id = mock_token_endpoint.id },
        config = {
          status_code  = 200,
          content_type = "application/json",
          body         = '{"access_token":"bac34121-bda2-42db-9029-cadbea67dd51","id_token":"eyJraWQiOiI3NWNkYmE1Ni1kMGFmLTQ3NDEtYjc5Yy02NWFlZWExOTY0MGMiLCJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJhdF9oYXNoIjoiWnhwYUNFcUo1OGt4R2lNWGpINTVIdyIsImF1ZCI6IjYzMWZhYmRlLTY0MjQtNDhiYy05NmRlLTk3ZjFlNjcwNjE0YiIsInN1YiI6IjVURGFUd3psTXhjcUlLZUxRR1dKWGlnd0xkX1NnYUhvUjd3djBHYWpQZmMiLCJhdXRoX3RpbWUiOjE2MjE4NTU1NDUsImlzcyI6Imh0dHA6Ly9rb25nLmxvY2FsIiwiZXhwIjoxNjIyNDYzNDUwLCJpYXQiOjE2MjI0MjAyNTAsIm94T3BlbklEQ29ubmVjdFZlcnNpb24iOiJvcGVuaWRjb25uZWN0LTEuMCJ9.Q2iSbJYLutmB5yj0MnAG1dvpX4EqHZMKR9KUd-ZqE8oXpZlh2mEz6n1_nOAmvNubratsXU-mPDeNN4PmjPckdAqAfZsPRHjq1HVcnmeM-YaIxbtfJ8H_NzxH_S8NnuR2_6932t-wN1Gfs7USfCvUZRsIUytHmfN3k9Ba-fcsM_IgzsdBYIsUD1y84cHK8icIfpoUqoyZfHb1Xf6AM28ZzSG8WdElmVcjwazFq8P45lSPYcVOYaM6L0-7lL9obY1tKpJqqsxjhwhj-MWNQJni4RFGRObV3AsIcVvmW_wjinaWntKqbc6uQA9FjDc7lVHZTjL6qmX8xTy1o7zjydfQhA","token_type":"bearer","expires_in":299}'
        },
      }

      local mock_userinfo_endpoint = bp.routes:insert({
        paths = {"/oxauth/restv1/userinfo"}
      })
      bp.plugins:insert {
        name = "request-termination",
        route = { id = mock_userinfo_endpoint.id },
        config = {
          status_code  = 200,
          content_type = "application/json",
          body         = '{"sub":"5TDaTwzlMxcqIKeLQGWJXigwLd_SgaHoR7wv0GajPfc","email_verified":true,"roles":["Admin"],"name":"Leandro Carneiro","given_name":"Leandro","family_name":"Carneiro","email":"leandro@carnei.ro"}'
        },
      }

      local route1 = bp.routes:insert({
        hosts = { "test1.com" },
      })
      -- add the plugin to test to the route we created
      -- kong executes at localhost:9000
      bp.plugins:insert {
        name = PLUGIN_NAME,
        route = { id = route1.id },
        config = {
          token_key     = 'b79143bf58085a98ba4056ede3b506db0d791de8a7802b1fe2cfe78509a06f9d',
          client_id     = 'my-client-id',
          client_secret = 'my-client-secret',
          gluu_url      = 'http://127.0.0.1:9000'
        },
      }

      -- start kong
      assert(helpers.start_kong({
        database   = strategy,
        nginx_conf = "spec/fixtures/custom_nginx.template",
        plugins = "bundled," .. PLUGIN_NAME,
      }))
    end)

    lazy_teardown(function()
      helpers.stop_kong(nil, true)
    end)

    before_each(function()
      client = helpers.proxy_client()
    end)

    after_each(function()
      if client then client:close() end
    end)


    describe("response", function()
      it("bad request when missing code and state", function()
        local r = client:get("/auth/edge/callback", {
          headers = {
            host = "test1.com"
          }
        })
        assert.response(r).has.status(400)
        local body = assert.response(r).has.jsonbody()
        assert.equal("Missing query param 'state' and/or 'code'", body['err'])
      end)

      it("bad request when missing state", function()
        local r = client:get("/auth/edge/callback?code=9af3070e-df93-4748-b871-9c5b180474b7", {
          headers = {
            host = "test1.com"
          }
        })
        assert.response(r).has.status(400)
        local body = assert.response(r).has.jsonbody()
        assert.equal("Missing query param 'state' and/or 'code'", body['err'])
      end)

      it("bad request when missing code", function()
        local r = client:get("/auth/edge/callback?state=eyJkIjoidjE7ZWRnZXRva2VuOzg2NDAwO2ZhbHNlO3Rlc3QxLmNvbTtodHRwOi8vdGVzdDEuY29tL2luZGV4Lmh0bWwiLCJ2IjoidjEiLCJlIjoiYmhIRFBEcGwzKzFQUmZuWUY3N0tmbDByN0l0WjBWU0hkeFBOd1BMMmNPTT0ifQ==", {
          headers = {
            host = "test1.com"
          }
        })
        assert.response(r).has.status(400)
        local body = assert.response(r).has.jsonbody()
        assert.equal("Missing query param 'state' and/or 'code'", body['err'])
      end)

      it("token issued - name=edgetoken ttl=86400 httponly=false iss=test1.com redir=http://test1.com/index.html", function()
        local r = client:get("/auth/edge/callback?code=9af3070e-df93-4748-b871-9c5b180474b7&state=eyJkIjoidjE7ZWRnZXRva2VuOzg2NDAwO2ZhbHNlO3Rlc3QxLmNvbTtodHRwOi8vdGVzdDEuY29tL2luZGV4Lmh0bWwiLCJ2IjoidjEiLCJlIjoiYmhIRFBEcGwzKzFQUmZuWUY3N0tmbDByN0l0WjBWU0hkeFBOd1BMMmNPTT0ifQ==", {
          headers = {
            host = "test1.com"
          }
        })
        assert.response(r).has.status(302)
        local header_location   = assert.response(r).has.header("Location")
        local header_set_cookie = assert.response(r).has.header("Set-Cookie")
        assert.equal("http://test1.com/index.html", header_location)
        assert.matches("^edgetoken=data=roles=%[\"Admin\"%]&sub=leandro@carnei.ro&iss=test1.com&name=Leandro Carneiro&domain=carnei.ro~acl=/%*~exp=%d+~hmac=%w+;version=1;path=/;secure;Max%-Age=86395$", header_set_cookie)
      end)

      it("token issued - name=edgetoken ttl=86400 httponly=true iss=test1.com redir=http://test1.com/index.html", function()
        local r = client:get("/auth/edge/callback?code=9af3070e-df93-4748-b871-9c5b180474b7&state=eyJkIjoidjE7ZWRnZXRva2VuOzg2NDAwO3RydWU7dGVzdDEuY29tO2h0dHA6Ly90ZXN0MS5jb20vaW5kZXguaHRtbCIsInYiOiJ2MSIsImUiOiJvcm5Jb2JGMXlWM0JKNzl2QTVuTTZKTlNYVU5DT0RMUE5KYlRRcllxRUY4PSJ9", {
          headers = {
            host = "test1.com"
          }
        })
        assert.response(r).has.status(302)
        local header_location   = assert.response(r).has.header("Location")
        local header_set_cookie = assert.response(r).has.header("Set-Cookie")
        assert.equal("http://test1.com/index.html", header_location)
        assert.matches("^edgetoken=data=roles=%[\"Admin\"%]&sub=leandro@carnei.ro&iss=test1.com&name=Leandro Carneiro&domain=carnei.ro~acl=/%*~exp=%d+~hmac=%w+;version=1;path=/;secure;Max%-Age=86395;httponly$", header_set_cookie)
      end)

      it("token issued - name=tokenname ttl=3600 httponly=true iss=test2.com redir=http://test2.com/foobar", function()
        local r = client:get("/auth/edge/callback?code=9af3070e-df93-4748-b871-9c5b180474b7&state=eyJkIjoidjE7dG9rZW5uYW1lOzM2MDA7dHJ1ZTt0ZXN0Mi5jb207aHR0cDovL3Rlc3QyLmNvbS9mb29iYXIiLCJ2IjoidjEiLCJlIjoiTTkxUjZPZEVXNlJjSHZWeEtDQ09RWDZsUUl2WExtRDdCa0xJL3hrekg2UT0ifQ==", {
          headers = {
            host = "test1.com"
          }
        })
        assert.response(r).has.status(302)
        local header_location   = assert.response(r).has.header("Location")
        local header_set_cookie = assert.response(r).has.header("Set-Cookie")
        assert.equal("http://test2.com/foobar", header_location)
        assert.matches("^tokenname=data=roles=%[\"Admin\"%]&sub=leandro@carnei.ro&iss=test2.com&name=Leandro Carneiro&domain=carnei.ro~acl=/%*~exp=%d+~hmac=%w+;version=1;path=/;secure;Max%-Age=3595;httponly$", header_set_cookie)
      end)

    end)

  end)
end
