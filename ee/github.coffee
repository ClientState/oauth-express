{EventEmitter} = require 'events'
querystring = require 'querystring'
https = require 'https'



class GithubEventEmitter extends EventEmitter

  constructor: ->
    @on 'requestToken', @requestToken
    @on 'receiveAccessToken', @receiveAccessToken
    #@on 'complete', exampleComplete
  ###
  exampleComplete: (access_token, user_data) ->
    db.sadd GITHUB_TOKEN_SET, access_token
    db.hset GITHUB_AUTH_HASH, access_token, user_data
  ###

  requestToken: (req, res, cb) =>
    # a request comes in from github with a code,
    # we want to POST back to github and save the token
    post_data = querystring.stringify {
      code: req.query.code
      client_id: process.env.GITHUB_CLIENT_ID
      client_secret: process.env.GITHUB_CLIENT_SECRET
    }
    options =
      method: 'POST'
      host: 'github.com'
      path: '/login/oauth/access_token'
      headers:
        "User-Agent": "skyl/express-oauth"
        "Accept": "application/json"

    ghpost = https.request(options, cb)
    ghpost.write post_data
    ghpost.end()

  receiveAccessToken: (req, str, cb) =>
    o = {}
    o.data = JSON.parse str
    o.status = "success"
    o.state = req.query.state
    o.provider = "github"

    access_token = o.data.access_token

    options =
      host: 'api.github.com'
      path: "/user?access_token=#{access_token}"
      headers: {
        "User-Agent": "skyl/express-oauth"
      }
    self = this
    user_req = https.request options, (gh_response) ->
      user_data = ''
      gh_response.on 'data', (chunk) -> user_data += chunk
      gh_response.on 'end', () ->
        o.user_data = JSON.parse user_data
        self.emit "complete", o
        cb o
    user_req.end()


module.exports.GithubEventEmitter = new GithubEventEmitter
