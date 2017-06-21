defmodule Dev3.Web.AuthController do
  use Dev3.Web, :controller

  alias Dev3.User
  alias Dev3.SlackBot
  alias Dev3.Web.OAuth.GitHub
  alias Dev3.Web.OAuth.Slack

  action_fallback Dev3.Web.AuthFallbackController

  @doc """
    Handles redirection to the provider Authorization URL
  """
  def index(conn, params) do
    authorize_url!(conn, params)
  end

  @doc """
    Defines the callback URL for the oauth worflow (redirect_uri)
  """
  def callback(conn, params) do
    handle_callback(conn, params)
  end

  # The Slack authorize URL is embedded in the "Add to Slack" button in the homepage
  defp authorize_url!(conn, %{"provider" => "slack"}), do: redirect conn, to: "/gitbruh.html"
  defp authorize_url!(conn, %{"provider" => "github", "user_id" => user_id}), do:
    redirect conn, external: GitHub.authorize_url!(state: user_id)
  defp authorize_url!(_, _), do: raise "Authorize : No matching provider available"

  defp handle_callback(conn, %{"provider" => "slack", "code" => code}) do
    with %{token: %{other_params: %{"ok" => true}} = oauth_params} <- Slack.get_token!(code: code),
         {:ok, %User{} = user} <- User.insert_or_update(to_slack_user_fields(oauth_params)),
         {:ok, %SlackBot{}} <- SlackBot.insert_or_update(to_slack_bot_fields(oauth_params)) do
           redirect conn, to: auth_path(conn, :index, "github", user_id: user.id)
    end
  end
  defp handle_callback(conn, %{"provider" => "github", "code" => code, "state" => user_id}) do
    with %{token: %{other_params: %{"scope" => _}}} = client <- GitHub.get_token!(code: code),
         github_user <- GitHub.get_user!(client),
         {:ok, %User{}} <- User.update(user_id, "github", to_github_user_fields(github_user)) do
           redirect conn, to: "/gitbruh.html"
    end
  end

  defp to_slack_user_fields(data) do
    %{
      slack_user_id: data.other_params["user_id"],
      slack_team_id: data.other_params["team_id"],
      slack_access_token: data.access_token
    }
  end

  defp to_slack_bot_fields(data) do
    %{
      slack_user_id: data.other_params["bot"]["bot_user_id"],
      slack_team_id: data.other_params["team_id"],
      slack_access_token: data.other_params["bot"]["bot_access_token"]
    }
  end

  defp to_github_user_fields(data) do
    %{
      github_access_token: data.access_token,
      github_user_id: data.user_id,
      github_id: data.id
    }
  end
end
