# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :dev3,
  ecto_repos: [Dev3.Repo]

# Configures the endpoint
config :dev3, Dev3.Web.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "MhKpLSGayFu8vTgqmmEnjdd3MHi65BQhKz70Ota1AUimXILyGC811frZFctZbQcj",
  render_errors: [view: Dev3.Web.ErrorView, accepts: ~w(json)],
  pubsub: [name: Dev3.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Configures Slack
config :dev3,
  slack_client_id: System.get_env("SLACK_CLIENT_ID"),
  slack_client_secret: System.get_env("SLACK_CLIENT_SECRET")

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
