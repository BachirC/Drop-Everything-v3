defmodule Dev3.Web.API.Slack.SlashCommandsController do
  use Dev3.Web, :controller

  alias Dev3.GitHubClient

  alias Dev3.User

  action_fallback Dev3.Web.API.Slack.SlashCommandsFallbackController

  def watch_repos(conn, %{"text" => args, "token" => verification_token} = params) do
    with :ok <- verify_token(verification_token),
         {:ok, repos} <- parse(args),
         user <- User.retrieve_with_slack(to_user_fields(params)),
         {:ok, repos_status} <- GitHubClient.watch_repos(user, repos) do
           send_resp(conn, 200, "")
    end
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
