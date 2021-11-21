# Kong Plugin Gluu Akamai Token

summary: Generate Akamai Token 2.0 based on Gluu (OpenID) flow.

<!-- BEGINNING OF KONG-PLUGIN DOCS HOOK -->
## Plugin Priority

Priority: **1000**

## Plugin Version

Version: **0.2.0**

## config

| name | type | required | validations | default |
|-----|-----|-----|-----|-----|
| state_algorithm | string | <pre>true</pre> | <pre>- one_of:<br/>  - sha256<br/>  - sha1<br/>  - md5</pre> | <pre>sha256</pre> |
| token_key | string | <pre>true</pre> | <pre>- match: ^[0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]$</pre> |  |
| token_algorithm | string | <pre>true</pre> | <pre>- one_of:<br/>  - sha256<br/>  - sha1<br/>  - md5</pre> | <pre>sha256</pre> |
| ssl_verify | boolean | <pre>true</pre> |  | <pre>true</pre> |
| client_id | string | <pre>true</pre> |  |  |
| client_secret | string | <pre>true</pre> |  |  |
| gluu_url | string | <pre>true</pre> |  |  |
| gluu_token_endpoint | string | <pre>true</pre> |  | <pre>/oxauth/restv1/token</pre> |
| gluu_userinfo_endpoint | string | <pre>true</pre> |  | <pre>/oxauth/restv1/userinfo</pre> |

## Usage

```yaml
plugins:
  - name: gluu-akamai-token
    enabled: true
    config:
      state_algorithm: sha256
      token_key: ''
      token_algorithm: sha256
      ssl_verify: true
      client_id: ''
      client_secret: ''
      gluu_url: ''
      gluu_token_endpoint: /oxauth/restv1/token
      gluu_userinfo_endpoint: /oxauth/restv1/userinfo

```
<!-- END OF KONG-PLUGIN DOCS HOOK -->
