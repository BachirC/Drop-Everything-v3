use Mix.Config

# For production, we often load configuration from external
# sources, such as your system environment. For this reason,
# you won't find the :http configuration below, but set inside
# Dev3.Web.Endpoint.load_from_system_env/1 dynamically.
# Any dynamic configuration should be moved to such function.
#
# Don't forget to configure the url host to something meaningful,
# Phoenix uses this information when generating URLs.
#
# Finally, we also include the path to a cache manifest
# containing the digested version of static files. This
# manifest is generated by the mix phoenix.digest task
# which you typically run after static files are built.
config :dev3, Dev3.Web.Endpoint,
  on_init: {Dev3.Web.Endpoint, :load_from_system_env, []},
  http: [port: {:system, "PORT"}],
  url: [scheme: "https", host: {:system, "HOST"}, port: 443],
  # cache_static_manifest: "priv/static/cache_manifest.json",
  # configuration for Distillery release
  root: ".",
  server: true,
  version: Mix.Project.config[:version]

# Do not print debug messages in production
config :logger, level: :warn

# ## SSL Support
#
# To get SSL working, you will need to add the `https` key
# to the previous section and set your `:url` port to 443:
#
config :dev3, Dev3.Web.Endpoint,
  secret_key_base: "${SECRET_KEY_BASE}"

# Configure your database
config :dev3, Dev3.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: System.get_env("DB_USER") || "${DB_USER}",
  password: System.get_env("DB_PASSWORD") || "${DB_PASSWORD}",
  database: System.get_env("DB_NAME") || "${DB_NAME}",
  hostname:  System.get_env("DB_HOST") || "${DB_HOST}",
  pool_size: 20

config :exq,
  name: Exq,
  host: "redis",
  port: 6379,
  namespace: "exq",
  concurrency: :infinite,
  queues: ["slack_messages"],
  poll_timeout: 50,
  scheduler_poll_timeout: 200,
  scheduler_enable: true,
  max_retries: 1,
  shutdown_timeout: 5000
#       ...
#       url: [host: "example.com", port: 443],
#       https: [:inet6,
#               port: 443,
#               keyfile: System.get_env("SOME_APP_SSL_KEY_PATH"),
#               certfile: System.get_env("SOME_APP_SSL_CERT_PATH")]
# Where those two env variables return an absolute path to
# the key and cert in disk or a relative path inside priv,
# for example "priv/ssl/server.key".
#
# We also recommend setting `force_ssl`, ensuring no data is
# ever sent via http, always redirecting to https:
#
#     config :dev3, Dev3.Web.Endpoint,
#       force_ssl: [hsts: true]
#
# Check `Plug.SSL` for all available options in `force_ssl`.

# ## Using releases
#
# If you are doing OTP releases, you need to instruct Phoenix
# to start the server for all endpoints:
#
config :phoenix, :serve_endpoints, true
#
# Alternatively, you can configure exactly which server to
# start per endpoint:
#
#     config :dev3, Dev3.Web.Endpoint, server: true
#
# Finally import the config/prod.secret.exs
# which should be versioned separately.
# import_config "prod.secret.exs"
