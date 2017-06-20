defmodule Dev3.Web.API.Slack.SlashCommandsControllerTest do
  use Dev3.Web.ConnCase
  use ExUnit.Case, async: true
  import Dev3.Web.Router.Helpers
  alias Dev3.Repo
  alias Dev3.User
  alias Dev3.GitHub.WatchedRepo

  # Config for plug tests
  @action :watch_repos
  @slack_command "/watchrepos"

  describe "plugs" do
    test "halt connection on bad verification token" do
      conn = post build_conn(), slash_commands_path(Dev3.Web.Endpoint, @action)

      assert conn.halted
      assert conn.status == Plug.Conn.Status.code(:ok)
    end

    test "halt connection when user not found" do
      conn = post build_conn(),
             slash_commands_path(Dev3.Web.Endpoint, @action),
             [token: Application.get_env(:dev3, Slack)[:verification_token],
              user_id: "non_existing",
              team_id: "non_existing"]

      assert conn.halted
      assert conn.status == Plug.Conn.Status.code(:ok)
    end

    test "halt connection when no args given" do
      user = insert_user()
      conn = post build_conn(),
             slash_commands_path(Dev3.Web.Endpoint, @action),
             [token: Application.get_env(:dev3, Slack)[:verification_token],
              user_id: user.slack_user_id,
              team_id: user.slack_team_id,
              command: @slack_command,
              text: ""]

      assert conn.halted
      assert conn.status == Plug.Conn.Status.code(:ok)
    end

    test "Limits argument while parsing" do
      user = insert_user()
      max_repos = Application.get_env(:dev3, :rate_limiter)[:max_repos_per_command]
      conn = build_valid_conn(:watch_repos,
                              user,
                              "/watchrepos",
                              "John/elixir-lang Sara/ex-http-client Org/private-repo Paul/non-existant Jack/LeGentleMan Foo/Bar John/elixir-lang John/elixir-lang John/elixir-lang")

      :timer.sleep(100)

      expected_result = ~w{John/elixir-lang Sara/ex-http-client Org/private-repo Paul/non-existant Jack/LeGentleMan Foo/Bar John/elixir-lang John/elixir-lang John/elixir-lang} |> Enum.take(max_repos)
      refute conn.halted
      assert conn.assigns[:args] == expected_result
    end

    test 'rate limit' do
      ignore = Application.get_env(:dev3, :rate_limiter)[:ignore]
      ignore_minus_1 = ignore - 1
      interval_ms = Application.get_env(:dev3, :rate_limiter)[:interval_ms]
      user = insert_user()

      for _ <- 1..ignore_minus_1, do: watch_repo_call(user)
      :timer.sleep(100)

      {count, remaining_count, _, _, _} = ExRated.inspect_bucket("#{user.id}:api/slack/slash_commands/watchrepos", interval_ms, ignore)
      assert count == ignore_minus_1
      assert remaining_count == 1

      conn = build_valid_conn(:watch_repos, user, "/watchrepos", "John/elixir-lang")
      :timer.sleep(100)
      assert conn.halted
      assert conn.status == Plug.Conn.Status.code(:ok)
      {count, remaining_count, _, _, _} = ExRated.inspect_bucket("#{user.id}:api/slack/slash_commands/watchrepos", interval_ms, ignore)

      assert count == ignore
      assert remaining_count == 0
    end
  end

  describe "/watchrepos" do
    test "success" do
      user = insert_user()
      conn = watch_repo_call(user)

      refute conn.halted
      assert conn.status == Plug.Conn.Status.code(:ok)
      assert Repo.aggregate(WatchedRepo, :count, :id) == 3
    end
  end

  describe "/unwatchrepos" do
    test "success" do
      user = insert_user()
      insert_watched_repos(user)
      conn = build_valid_conn(:unwatch_repos, user, "/unwatchrepos", "Josh/to-be-unwatched Joe/not-watched")

      :timer.sleep(100)

      refute conn.halted
      assert conn.status == Plug.Conn.Status.code(:ok)
      assert Repo.aggregate(WatchedRepo, :count, :id) == 0
    end
  end

  defp build_valid_conn(action, user, command, text) do
    post build_conn(),
      slash_commands_path(Dev3.Web.Endpoint, action),
      [token: Application.get_env(:dev3, Slack)[:verification_token],
       user_id: user.slack_user_id,
       team_id: user.slack_team_id,
       command: command,
       text: text]
  end

  defp insert_user do
    Repo.insert!(%User{slack_team_id: "ST1", slack_user_id: "SU1", slack_access_token: "SAT1"})
  end

  defp insert_watched_repos(user) do
    Repo.insert!(%WatchedRepo{github_id: 1, full_name: "Josh/to-be-unwatched", user_id: user.id})
  end

  defp watch_repo_call(user) do
    conn = build_valid_conn(:watch_repos,
                            user,
                            "/watchrepos",
                            "John/elixir-lang Sara/ex-http-client Org/private-repo Paul/non-existant")
    :timer.sleep(100)
    conn
  end
end
