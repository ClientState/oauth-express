{EventEmitter} = require "events"
request = require "supertest"
app = require("express")()
{assert} = require "chai"


class MockResponse extends EventEmitter
  constructor: (@statusCode, body) ->
    self = this
    setTimeout(() ->
      self.emit "data", body
      self.emit "end"
    , 1)


class MockGithub extends EventEmitter

  constructor: ->
    @eventListeners = {}
    @emitCounts = {}
    @on 'requestToken', @requestToken
    @on 'receiveAccessToken', @receiveAccessToken
    # this is like a user added it (write to db)
    @on 'complete', @onComplete
  onComplete: (object) ->
    @emitCounts['complete'] ?= 0
    @emitCounts['complete']++

  requestToken: (req, res, cb) =>
    @emitCounts['requestToken'] ?= 0
    @emitCounts['requestToken']++
    cb(new MockResponse(200, '{"access_token": "boom"}'))
  receiveAccessToken: (req, str, cb) =>
    @emitCounts['receiveAccessToken'] ?= 0
    @emitCounts['receiveAccessToken']++
    @emit "complete", {"access_token": "boom"}
    cb '{}'


# nice article
# pragprog.com decouple-your-apps-with-eventdriven-coffeescript
{EVENT_EMITTERS} = require("../config")
EVENT_EMITTERS.github = new MockGithub

{auth_provider_redirect, auth_callback} = require "../handlers"

app.get '/auth/:provider', auth_provider_redirect
app.get '/auth_callback/:provider', auth_callback


describe 'Github redirect redirects', () ->
  it "puts the github redirect on it's skin", (done) ->
    request(app)
      .get('/auth/github?opts={"state": "foobar"}')
      .expect(302)
      .end (err, res) ->
        assert.ok res.headers.location.indexOf("github.com") > -1
        done()

describe 'get Emits events or else', () ->
  it 'gets the hose again', (done) ->
    request(app)
      .get('/auth_callback/github')
      .expect(200)
      .end (err, res) ->
        ec = EVENT_EMITTERS.github.emitCounts
        assert.ok ec.requestToken is 1
        assert.ok ec.receiveAccessToken is 1
        assert.ok ec.complete is 1
        done()


