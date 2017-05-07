defmodule Dev3.Web.API.Slack.SlashCommandsController do
  use Dev3.Web, :controller

  alias Dev3.User
  alias Dev3.GitHub.WatchedRepo

  action_fallback Dev3.Web.API.Slack.SlashCommandsFallbackController

  plug :verify_token
  plug :assign_user
  plug :parse_args, "before commands with args" when action in [:watch_repos, :unwatch_repos]

  @github_client   Application.get_env(:dev3, :github_client)
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
  def watch_repos(%{assigns: %{user: user, args: args}} = conn, _params) do
    {:ok, repos_status} = @github_client.create_webhooks(user, args)

    valid_repos = listify(repos_status)
    {_, nil} = WatchedRepo.insert_watched(user, valid_repos)

    repos_names = for {k, v} <- repos_status, into: %{}, do: {k, Enum.map(v, fn repo -> repo.full_name end)}
    # Somehow, piping directly on the comprehension has unexpected results
    repos_names = repos_names |> Map.put(:not_found, args -- Enum.map(valid_repos, fn repo -> repo.full_name end))
    with :ok <- @slack_messenger.notify("watch_repos_response", user, repos_names) do
      send_resp(conn, :ok, "/watchrepos successful")
    end
  end

  @doc """
    Endpoint for Slack /unwatchrepos command.
    The command takes a whitespace-separated list of github repos full_name (ex.: username/myrepo).
    It stops watching every repo given by the user but the corresponding webhooks are not
    deleted !
  """
  def unwatch_repos(%{assigns: %{user: user, args: args}} = conn, _params) do
    watched_repos = Enum.map(WatchedRepo.list(user), fn x -> x.full_name end)
    repos_not_found = args -- watched_repos
    repos_status = %{unwatched: args -- repos_not_found, not_found: repos_not_found}

      with {_, nil}     <- WatchedRepo.delete_unwatched(user, args),
        :ok <- @slack_messenger.notify("unwatch_repos_response", user, repos_status) do
        send_resp(conn, :ok, "/unwatchrepos successful")
      end
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
    @slack_messenger.notify("no_args_response", conn.assigns[:user], command)
    conn |> send_resp(:ok, "Args parsing error") |> halt
  end

  defp listify(map), do: map |> Map.values() |> List.flatten()
end
