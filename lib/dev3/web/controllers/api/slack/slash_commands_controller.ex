defmodule Dev3.Web.API.Slack.SlashCommandsController do
  use Dev3.Web, :controller

  alias Dev3.GitHubClient
  alias Dev3.User
  alias Dev3.GitHub.WatchedRepo

  action_fallback Dev3.Web.API.Slack.SlashCommandsFallbackController

  plug :set_up

  @doc """
    Endpoint for Slack /watchrepos command.
    The command takes a whitespace-separated list of github repos full_name (ex.: username/myrepo).
    It creates a github webhook to /api/github/webhook for each repo allowed and start watching
    the repos by the user.
  """
  def watch_repos(%{assigns: %{user: user, args: args}} = conn, _params) do
    with {:ok, repos_status} <- GitHubClient.create_webhooks(user, args) do
      WatchedRepo.insert_watched(user, repos_to_watch(repos_status))
      send_resp(conn, 200, "")
    end
  end

  @doc """
    Endpoint for Slack /unwatchrepos command.
    The command takes a whitespace-separated list of github repos full_name (ex.: username/myrepo).
    It stops watching every repo given by the user but the corresponding webhooks are not
    deleted !
  """
  def unwatch_repos(%{assigns: %{user: user, args: args}} = conn, _params) do
    WatchedRepo.delete_unwatched(user, args)
    send_resp(conn, 200, "")
  end

  defp set_up(%{params: %{"text" => args, "token" => verification_token} = params} = conn, _) do
    with :ok <- verify_token(verification_token),
         {:ok, args} <- parse(args),
         user <- User.retrieve_with_slack(to_user_fields(params)) do
           conn
           |> assign(:user, user)
           |> assign(:args, args)
         end
  end

  defp repos_to_watch(repos) do
    repos
    |> Map.take([:created, :noop])
    |> Map.values()
    |> List.flatten()
  end

  defp verify_token(token) do
    if token == Application.get_env(:dev3, Slack)[:verification_token] do
      :ok
    else
      {:verification_token_mismatch, "Token mismatch"}
    end
  end

  # TODO: Send Slack message to alert the user
  defp parse(""), do: {:parse_error, "Please provide at least one repo's full name (ex: user/repo-name)"}
  defp parse(args), do: {:ok, String.split(args, " ")}

  defp to_user_fields(params) do
    %{
      slack_team_id: params["team_id"],
      slack_user_id: params["user_id"]
    }
  end
end
