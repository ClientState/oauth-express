{CLIENT_IDS, PROVIDER_URLS, EVENT_EMITTERS} = require "./config"

#app.get '/auth/:provider', auth_provider_redirect
auth_provider_redirect = (req, res) ->
  provider = req.param "provider"
  URL = PROVIDER_URLS[provider](
    CLIENT_IDS[provider], JSON.parse(req.query.opts)["state"])
  res.redirect(URL)
  res.send()

# the auth_callback is now strictly for a browser popup flow .. hrm ..
# TODO - support other flows
# console.log "REDIRECT_URL=", process.env.OAUTH_REDIRECT_URL
auth_callback_template = (o) -> """
<script>
  window.opener.postMessage('#{JSON.stringify o}',
                            '#{process.env.OAUTH_REDIRECT_URL}')
</script>
"""
#app.get '/auth_callback/:provider', auth_callback
auth_callback = (req, res) ->
  provider = req.param "provider"
  provider_event_emitter = EVENT_EMITTERS[provider]
  cb = (provider_response) ->
    str = ''
    provider_response.on 'data', (chunk) ->
      str += chunk
    provider_response.on 'end', () ->
      provider_event_emitter.emit "receiveAccessToken", req, str, (o) ->
        console.log "provider_event_emitter"
        s = auth_callback_template o
        console.log s
        return res.send s

  provider_event_emitter.emit "requestToken", req, res, cb

module.exports.auth_provider_redirect = auth_provider_redirect
module.exports.auth_callback = auth_callback
