# Kong Plugin Gluu Akamai Token

summary: Generate Akamai Token 2.0 based on Gluu (OpenID) flow.

<!-- BEGINNING OF KONG-PLUGIN DOCS HOOK -->
## Plugin Priority

Priority: **1000**

## Plugin Version

Version: **0.1.0**

## Configs

| name | type | required | default | validations |
| ---- | ---- | -------- | ------- | ----------- |
| config.state_algorithm | **string** | true | <pre>sha256</pre> | <pre>- one_of:<br/>  - sha256<br/>  - sha1<br/>  - md5</pre> |
| config.token_key | **string** | true |  | <pre>- match: "^[0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]$"</pre> |
| config.token_algorithm | **string** | true | <pre>sha256</pre> | <pre>- one_of:<br/>  - sha256<br/>  - sha1<br/>  - md5</pre> |
| config.ssl_verify | **boolean** | true | <pre>true</pre> |  |
| config.client_id | **string** | true |  |  |
| config.client_secret | **string** | true |  |  |
| config.gluu_url | **string** | true |  |  |
| config.gluu_token_endpoint | **string** | true | <pre>/oxauth/restv1/token</pre> |  |
| config.gluu_userinfo_endpoint | **string** | true | <pre>/oxauth/restv1/userinfo</pre> |  |

## Usage

```yaml
---
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
    gluu_token_endpoint: "/oxauth/restv1/token"
    gluu_userinfo_endpoint: "/oxauth/restv1/userinfo"
```
<!-- END OF KONG-PLUGIN DOCS HOOK -->
