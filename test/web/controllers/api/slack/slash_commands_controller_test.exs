defmodule Dev3.Web.API.Slack.SlashCommandsControllerTest do
  use Dev3.Web.ConnCase
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
      assert conn.resp_body == "Invalid token"
    end

    test "halt connection when user not found" do
      conn = post build_conn(),
             slash_commands_path(Dev3.Web.Endpoint, @action),
             [token: Application.get_env(:dev3, Slack)[:verification_token],
              user_id: "non_existing",
              team_id: "non_existing"]

      assert conn.halted
      assert conn.status == Plug.Conn.Status.code(:ok)
      assert conn.resp_body == "User not found"
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
      assert conn.resp_body == "Args parsing error"
    end
  end

  describe "/watchrepos" do
    test "success" do
      user = insert_user()
      conn = build_valid_conn(:watch_repos,
                              user,
                              "/watchrepos",
                              "John/elixir-lang Sara/ex-http-client Org/private-repo Paul/non-existant")

      refute conn.halted
      assert conn.status == Plug.Conn.Status.code(:ok)
      assert conn.resp_body == "/watchrepos successful"
      assert Repo.aggregate(WatchedRepo, :count, :id) == 3
    end
  end

  describe "/unwatchrepos" do
    test "success" do
      user = insert_user()
      insert_watched_repos(user)
      conn = build_valid_conn(:unwatch_repos, user, "/unwatchrepos", "Josh/to-be-unwatched Joe/not-watched")

      refute conn.halted
      assert conn.status == Plug.Conn.Status.code(:ok)
      assert conn.resp_body == "/unwatchrepos successful"
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
end
