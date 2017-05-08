use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :dev3, Dev3.Web.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :dev3, Dev3.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: System.get_env("DATABASE_POSTGRESQL_USERNAME") || "postgres",
  password: System.get_env("DATABASE_POSTGRESQL_PASSWORD") || "",
  database: "dev3_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

config :dev3, Slack,
  verification_token: System.get_env("SLACK_VERIFICATION_TOKEN"),
  webhook_events: ~w(pull_request pull_request_review pull_request_review_comment)

config :dev3, GitHub,
  webhook_events: ~w(pull_request pull_request_review pull_request_review_comment)

config :dev3, :github_client, Dev3.GitHubClient.InMemory
config :dev3, :slack_messenger, Dev3.SlackMessenger.InMemory
