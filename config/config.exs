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

config :dev3, :bot_username, "DEv3"

config :prometheus, Dev3.PhoenixInstrumenter,
  controller_call_labels: [:controller, :action],
  duration_buckets: [10, 25, 50, 100, 250, 500, 1000, 2500, 5000,
                     10_000, 25_000, 50_000, 100_000, 250_000, 500_000,
                     1_000_000, 2_500_000, 5_000_000, 10_000_000],
  registry: :default,
  duration_unit: :microseconds

config :prometheus, Dev3.PipelineInstrumenter,
  labels: [:status_class, :method, :host, :scheme, :request_path],
  duration_buckets: [10, 100, 1_000, 10_000, 100_000,
                     300_000, 500_000, 750_000, 1_000_000,
                     1_500_000, 2_000_000, 3_000_000],
  registry: :default,
  duration_unit: :microseconds

# as well as ...
config :dev3, Dev3.Repo,
  loggers: [Dev3.RepoInstrumenter] # and maybe Ecto.LogEntry? Up to you
# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
