{GithubEventEmitter} = require "./ee/github"

module.exports.PROVIDER_URLS =
  github: (id, state) ->
    "https://github.com/login/oauth/authorize?client_id=#{id}&state=#{state}"

module.exports.CLIENT_IDS =
  "github": process.env.GITHUB_CLIENT_ID

module.exports.CLIENT_SECRETS =
  "github": process.env.GITHUB_CLIENT_SECRET

module.exports.EVENT_EMITTERS =
  "github": GithubEventEmitter
