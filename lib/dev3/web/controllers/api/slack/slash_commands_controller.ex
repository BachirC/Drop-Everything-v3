defmodule Dev3.Web.API.Slack.SlashCommandsController do
  use Dev3.Web, :controller
  alias Dev3.User
  require Logger
  import Dev3.Web.RateLimit

  action_fallback Dev3.Web.API.Slack.SlashCommandsFallbackController
  @rate_limiter_conf Application.get_env(:dev3, :rate_limiter)
  @slack_messenger Application.get_env(:dev3, :slack_messenger)

  plug :verify_token
  plug :assign_user
  plug :rate_limit, @rate_limiter_conf when action in [:watch_repos, :unwatch_repos, :list_repos]
  plug :parse_args, "before commands with args" when action in [:watch_repos, :unwatch_repos]

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
    send_resp(conn, :ok, "")
  end

  @doc """
    Endpoint for Slack /unwatchrepos command.
    The command takes a whitespace-separated list of github repos full_name (ex.: username/myrepo).
    It stops watching every repo given by the user but the corresponding webhooks are not
    deleted !
  """
  def unwatch_repos(conn, _params) do
    Dev3.Tasks.UnwatchReposHandler.start(conn.assigns)
    send_resp(conn, :ok, "")
  end

  @doc """
    Endpoint for Slack /listrepos command.
    The command doesn't take any arguments.
    It shows the list of watched repos.
  """
  def list_repos(conn, _params) do
    Dev3.Tasks.ListReposHandler.start(conn.assigns)
    send_resp(conn, :ok, "")
  end

  defp verify_token(%{params: %{"token" => token}} = conn, _) do
    if token == Application.get_env(:dev3, Slack)[:verification_token] do
      conn
    else
      body = conn.body_params
      Logger.error fn -> "[SlashCommands.InvalidSlackVerificationTokenError slack_user_id=#{body["user_id"]} slack_team_id=#{body["team_id"]}] Invalid verification token" end
      conn |> send_resp(:ok, "") |> halt
    end
  end
  defp verify_token(conn, _) do
    Logger.error fn -> "[SlashCommands.InvalidSlackVerificationTokenError] Invalid verification token" end
    conn |> send_resp(:ok, "") |> halt
  end

  defp assign_user(%{params: %{"team_id" => team_id, "user_id" => user_id}} = conn, _) do
    if user = User.retrieve_with_slack(%{slack_team_id: team_id, slack_user_id: user_id}) do
      conn |> assign(:user, user)
    else
      Logger.error fn -> "[SlashCommands.SlackUserNotFoundError slack_user_id=#{user_id} slack_team_id=#{team_id}] User not found" end
      conn |> send_resp(:ok, "") |> halt
    end
  end
  defp assign_user(conn, _) do
    Logger.error fn -> "[SlashCommands.SlackUserNotFoundError] User not found" end
    conn |> send_resp(:ok, "") |> halt
  end

  defp parse_args(%{params: %{"text" => args, "command" => command}} = conn, _) do
    case parse(args) do
      {:ok, parsed_args} -> assign(conn, :args, parsed_args)
      :no_args_error     -> handle_no_args_error(conn, command)
    end
  end
  defp parse_args(conn, _) do
    conn |> send_resp(:ok, "") |> halt
  end

  defp parse(args) when is_nil(args) or args == "", do: :no_args_error
  defp parse(args), do: {:ok, args |> String.split(" ") |> limit_repos}

  defp handle_no_args_error(conn, command) do
    Logger.warn fn -> "[SlashCommands.NoArgsError user_id=#{conn.assigns[:user].id} command=#{command}] No args for slash command" end
    @slack_messenger.notify(:no_args_response, conn.assigns[:user], command)
    conn |> send_resp(:ok, "") |> halt
  end

  defp limit_repos(parsed_args) do
    parsed_args |> Enum.take(@rate_limiter_conf[:max_repos_per_command])
  end
end
