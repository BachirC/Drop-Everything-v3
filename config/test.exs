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
  username: "postgres",
  password: "",
  database: "dev3_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

config :dev3, Slack,
  verification_token: System.get_env("SLACK_VERIFICATION_TOKEN")

config :dev3, GitHub,
  webhook_events: ~w(issues issue_comment pull_request pull_request_review)a,
  message_type_by_action: %{{"pull_request", "review_requested"} => :review_requested,
                            {"pull_request_review", "submitted"} => :review_submitted,
                            {"issues", "opened"}                 => :tagged_in_issue,
                            {"issue_comment", "created"}         => :tagged_in_issue_comment}

config :dev3, :github_client, Dev3.GitHubClient.InMemory
config :dev3, :slack_messenger, Dev3.SlackMessenger.InMemory
config :dev3, :webhook_parser, Dev3.GitHub.WebhookParser.Mock
