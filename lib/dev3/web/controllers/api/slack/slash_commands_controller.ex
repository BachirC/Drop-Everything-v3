defmodule Dev3.Web.API.Slack.SlashCommandsController do
  use Dev3.Web, :controller
  alias Dev3.User

  action_fallback Dev3.Web.API.Slack.SlashCommandsFallbackController

  plug :verify_token
  plug :assign_user
  plug :parse_args, "before commands with args" when action in [:watch_repos, :unwatch_repos]

  @slack_messenger Application.get_env(:dev3, :slack_messenger)

  @doc """
    Endpoint for Slack /watchrepos command.
    The command takes a whitespace-separated list of github repos full_name (ex.: username/myrepo).
    It creates a github webhook to /api/github/webhook for each repo (if the user have the rights) and start watching
    the repos by the user.
    It sends a Slack message to the user with the following structure :
    - List of newly watched repos for which a GitHub webhook has been added
    - List of newly watched repos for which a GitHub webhook already exists
    - List of newly watched repos for which the user has not enough permission to add a GitHub\
      webhook.
    - List of repos that have not been found.
  """
  def watch_repos(conn, _params) do
    Dev3.Tasks.WatchReposHandler.start(conn.assigns)
    send_resp(conn, :ok, "/watchrepos successful")
  end

  @doc """
    Endpoint for Slack /unwatchrepos command.
    The command takes a whitespace-separated list of github repos full_name (ex.: username/myrepo).
    It stops watching every repo given by the user but the corresponding webhooks are not
    deleted !
  """
  def unwatch_repos(conn, _params) do
    Dev3.Tasks.UnwatchReposHandler.start(conn.assigns)
    send_resp(conn, :ok, "/unwatchrepos successful")
  end

  defp verify_token(%{params: %{"token" => token}} = conn, _) do
    if token == Application.get_env(:dev3, Slack)[:verification_token] do
      conn
    else
      conn |> send_resp(:ok, "") |> halt
    end
  end
  defp verify_token(conn, _) do
    conn |> send_resp(:ok, "Invalid token") |> halt
  end

  defp assign_user(%{params: %{"team_id" => team_id, "user_id" => user_id}} = conn, _) do
    if user = User.retrieve_with_slack(%{slack_team_id: team_id, slack_user_id: user_id}) do
      conn |> assign(:user, user)
    else
      conn |> send_resp(:ok, "User not found") |> halt
    end
  end
  defp assign_user(conn, _) do
    conn |> send_resp(:ok, "User not found") |> halt
  end

  defp parse_args(%{params: %{"text" => args, "command" => command}} = conn, _) do
    case parse(args) do
      {:ok, parsed_args} -> assign(conn, :args, parsed_args)
      :no_args_error -> handle_no_args_error(conn, command)
    end
  end
  defp parse_args(conn, _) do
    conn |> send_resp(:ok, "Args parsing error") |> halt
  end

  defp parse(args) when is_nil(args) or args == "", do: :no_args_error
  defp parse(args), do: {:ok, String.split(args, " ")}

  defp handle_no_args_error(conn, command) do
    @slack_messenger.notify(:no_args_response, conn.assigns[:user], command)
    conn |> send_resp(:ok, "Args parsing error") |> halt
  end
end
