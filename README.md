# Drop Everything (DEv3)


## Overview

DEv3 is a Slack app leveraging GitHub webhooks to notify you when you are mentioned on GitHub, being requested for a pull request review or when someone submits a review to one of your PRs. It also gives you the ability to choose which GitHub repos to watch, mute issues (or pull requests) and snooze messages.

Other types of messages will be added in the future !

- Installation (Not available yet)
- [Documentation](https://bachirc.github.io/Drop-Everything-v3-web/doc.html)

## Set up dev environment

### Install Elixir/Phoenix

* [Install Elixir](https://elixir-lang.org/install.html)
* Install Phoenix 1.3.0-rc : `$ mix archive.install https://github.com/phoenixframework/archives/raw/master/phx_new.ez`

### Phoenix setup

* Fork the repo
* Install dependencies with `mix deps.get`
* Set up your database config in `config/dev.exs`
* Create and migrate your database with `mix ecto.create && mix ecto.migrate`
* Create a `.env` file at the root of the project

### Install ngrok

* Download and Install [ngrok](https://ngrok.com/)
* Launch `ngrok http -bind-tls=true 4000` or on whatever port your Phoenix app is listenning on.
You should have something like this :

~~~bash
$ ngrok http -bind-tls=true 4000
def ok
Session Status                online
Update                        update ava		ilable (version 2.2.4, Ctrl-U to update)
Version                       2.2.3
Region                        United States (us)
Web Interface                 http://127.0.0.1:4040
Forwarding                    http://b2hfwe81.ngrok.io -> localhost:4000
Forwarding                    https://b2hfwe81.ngrok.io -> localhost:4000
~~~

* Take note of the https link `https://b2hfwe81.ngrok.io`, we'll need it later. Be sure not to stop ngrok because the URL generated will change at every restart. If you have to, don't forget to replace every reference to this link in the following configurations

### Set up Slack app

* Go to https://api.slack.com/apps and create a new app

##### OAuth configuration
* On the left menu, go to __OAuth & Permissions__ and add `https://b2hfwe81.ngrok.io/auth/slack/callback` as a redirect URL
* In the same section, add the permission scopes needed by the app : bot, commands, chat:write:bot, im:read

##### App configuration
* Go to __Bot Users__ and add a bot
* Add `/watchr` and `/unwatchr` slash commands [(More details](https://bachirc.github.io/Drop-Everything-v3-web/doc.html#Slack-commands) on DEv3 slack commands). Go to __Slash Commands__ and add two slash commands. Parameters :

	- Command : `/watchr` and `/unwatchr` (Note : Avoid using `/watchrepos` and `/unwatchrepos` for naming the commands, they are reserved to DEv3 in production)
	- Request URL : `https://b2hfwe81.ngrok.io/api/slack/slash_commands/watchrepos` and `https://b2hfwe81.ngrok.io/api/slack/slash_commands/unwatchrepos` (keep "watchrepos" and "unwatchrepos" in the URLs !)

##### Phoenix app configuration

* Set Slack environment variables in the `.env` file created previously. You can find them in the __Basic Information__ section :

```
	export SLACK_CLIENT_ID=<slack_client_id>
	export SLACK_CLIENT_SECRET=<slack_client_secret>
	export SLACK_VERIFICATION_TOKEN=<slack_verification_token>
	export SLACK_REDIRECT_URI=https://b2hfwe81.ngrok.io/auth/slack/callback
```
* In __Manage Distribution__, grab the Slack button HTML and replace the one in `/priv/static/dev3.html` in the Phoenix app. You will need this button to install DEv3 to your Slack team

### Set up GitHub app

##### App configuration

* Go to https://github.com/settings/applications/new to create a new GitHub app. Set the authorization callback to `https://b2hfwe81.ngrok.io/auth/github/callback`

##### Phoenix app configuration

* Set GitHub environment variables in the `.env` file created previously

```
	export GITHUB_CLIENT_ID=<github_client_id>
	export GITHUB_CLIENT_SECRET=<github_client_secret>
	export GITHUB_REDIRECT_URI=https://b2hfwe81.ngrok.io/auth/github/callback
	export GITHUB_SCOPE=write:repo_hook,repo
```

### Getting started

* In `config/dev.exs`, change the `url` param to use your ngrok url. This will tell Phoenix to use this url as hostname for your app :

```
config :dev3, Dev3.Web.Endpoint,
  http: [port: 4000],
  url: [scheme: "https", host: "b2hfwe81.ngrok.io", port: "443"],
```

* `source .env`
* `mix phx.server`
* Visit `https://b2hfwe81.ngrok.io/dev3.html` and install DEv3 using the button. This will create a `User` using your Slack and GitHub information and a `SlackBot` in DEv3. Fire up a new elixir console `iex -S mix` and check that everything worked as expected : `Dev3.Repo.all(Dev3.User)` and `Dev3.Repo.all(Dev3.SlackBot)`
* Start hacking :)

## Learn more

  * Official website: http://www.phoenixframework.org/
  * Guides: http://phoenixframework.org/docs/overview
  * Docs: https://hexdocs.pm/phoenix
  * Mailing list: http://groups.google.com/group/phoenix-talk
  * Source: https://github.com/phoenixframework/phoenix
