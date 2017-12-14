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

config :dev3, :bot_username, "GitBruh"

config :dev3, Slack,
  client_id: System.get_env("SLACK_CLIENT_ID") || "${SLACK_CLIENT_ID}",
  client_secret: System.get_env("SLACK_CLIENT_SECRET") || "${SLACK_CLIENT_SECRET}",
  verification_token: System.get_env("SLACK_VERIFICATION_TOKEN") || "${SLACK_VERIFICATION_TOKEN}"

config :dev3, GitHub,
  client_id: System.get_env("GITHUB_CLIENT_ID") || "${GITHUB_CLIENT_ID}",
  client_secret: System.get_env("GITHUB_CLIENT_SECRET") || "${GITHUB_CLIENT_SECRET}",
  scope: System.get_env("GITHUB_SCOPE") || "${GITHUB_SCOPE}",
  webhook_events: ~w(issues issue_comment pull_request pull_request_review)a,
  message_types_by_action: %{{"pull_request", "review_requested"} => [:review_requested],
                             {"pull_request_review", "submitted"} => [:review_submitted],
                             {"issues", "opened"}                 => [:tagged_in_issue],
                             {"issue_comment", "created"}         => [:tagged_in_issue_comment,
                                                                     :notify_owner_on_issue_comment]}

config :dev3, :github_client, Dev3.GitHubClient.HTTPClient
config :dev3, :slack_messenger, Dev3.SlackMessenger.HTTPClient
config :dev3, :webhook_parser, Dev3.GitHub.WebhookParser.Real

config :exq,
  name: Exq,
  host: "127.0.0.1",
  port: 6379,
  namespace: "exq",
  concurrency: :infinite,
  queues: ["slack_messages"],
  poll_timeout: 50,
  scheduler_poll_timeout: 200,
  scheduler_enable: true,
  max_retries: 1,
  shutdown_timeout: 5000

config :exq_ui,
  server: true

config :mix_docker, image: "bachirc/gitbruh"
config :dev3, :rate_limiter,
  max_requests: 5,
  ignore: 7,
  interval_ms: 60_000,
  max_repos_per_command: 5

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
