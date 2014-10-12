express-oauth
=============

Add oauth client to your express server.

require the handlers and add them to your app.

    handlers = require("express-oauth").handlers;

    app.get('/auth/:provider', handlers.auth_provider_redirect);
    app.get('/auth_callback/:provider', handlers.oauth_callback);

You have to rerun your app with environment variables set:

    OAUTH_REDIRECT_URL=http://domain-where-user-ends-up.com

So, maybe you have a page at `http://localhost:8080` that wants to
initiate OAUTH. The app running express-oauth may be at `http://localhost:3000`.
You can use Oauth.io to initiate the auth with a popup - on `http://localhost:8080`:

    OAuth.setOAuthdURL("http://localhost:3000")
    OAuth.popup "github", (err, provider_data) ->
      access_token = provider_data.access_token

So, to run the `express-oauth`-enabled app on localhost:3000,
you set the OAUTH_REDIRECT_URL to `http://localhost:8080`.

    $ OAUTH_REDIRECT_URL=http://localhost:8090 nodemon server
    Listening on port 3000

To use Github as the Oauth provider, you must also set the env variables,
`GITHUB_CLIENT_SECRET` and `GITHUB_CLIENT_ID` (more providers coming soon).

Once we have the access_token and user data back from github,
we emit an event that can be used to write to a db or have other side effects:

    githubee = require("express-oauth").emitters.github
    githubee.on 'complete', (data) ->
      db.write data.access_token, JSON.stringify(data.user_data)
