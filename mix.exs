defmodule Dev3.Mixfile do
  use Mix.Project

  def project do
    [app: :dev3,
     version: "0.0.#{committed_at()}",
     elixir: "~> 1.4",
     elixirc_paths: elixirc_paths(Mix.env),
     compilers: [:phoenix, :gettext] ++ Mix.compilers,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     aliases: aliases(),
     deps: deps(),
     test_coverage: [tool: ExCoveralls],
     preferred_cli_env: ["coveralls": :test, "coveralls.detail": :test, "coveralls.post": :test, "coveralls.html": :test]]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [mod: {Dev3.Application, []},
     extra_applications: [:logger,
                          :oauth2,
                          :httpoison,
                          :tentacat,
                          :slack,
                          :exq,
                          :exq_ui,
                          :prometheus_ex,
                          :prometheus_ecto,
                          :prometheus_phoenix,
                          :prometheus_plugs,
                          :prometheus_process_collector]]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [{:phoenix, "~> 1.3.0-rc", override: true},
     {:phoenix_pubsub, "~> 1.0"},
     {:phoenix_ecto, "~> 3.2"},
     {:postgrex, ">= 0.0.0"},
     {:phoenix_html, "~> 2.6"},
     {:phoenix_live_reload, "~> 1.0", only: :dev},
     {:gettext, "~> 0.11"},
     {:cowboy, "~> 1.0"},
     {:httpoison, "~> 0.11.1"},
     # HACK: Overrides retired version 1.6.6 default to httpoison :
     # https://github.com/edgurgel/httpoison/issues/226
     {:hackney, "~> 1.7.0", override: true},
     {:poison, "~> 3.0"},
     {:oauth2, "~> 0.9"},
     {:tentacat, "~> 0.5"},
     {:slack, "~> 0.11.0"},
     {:credo, "~> 0.7", only: [:dev, :test]},
     {:excoveralls, "~> 0.6", only: :test},
     {:exq, "~> 0.8.6"},
     {:exq_ui, "~> 0.8.6"},
     {:distillery, "~> 1.4"},
     {:prometheus_ex, "~> 1.0"},
     {:prometheus_ecto, "~> 1.0"},
     {:prometheus_phoenix, "~> 1.0"},
     {:prometheus_plugs, "~> 1.0"},
     {:prometheus_process_collector, "~> 1.0"}]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    ["ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
     "ecto.reset": ["ecto.drop", "ecto.setup"],
     "test": ["ecto.create --quiet", "ecto.migrate", "test"]]
  end

  # Unix timestamp of the last commit.
  defp committed_at do
    System.cmd("git", ~w[log -1 --date=short --pretty=format:%ct]) |> elem(0)
  end
end
