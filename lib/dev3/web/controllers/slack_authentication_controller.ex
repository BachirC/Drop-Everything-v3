defmodule Dev3.Web.SlackAuthenticationController do
  use Dev3.Web, :controller

  require Logger

  @slack_fields ~w(access_token user_id team_id bot)
  @bot_fields ~w(bot_access_token bot_user_id)
  @slack_oauth_access_url ~s(https://slack.com/api/oauth.access?)

  action_fallback Dev3.Web.FallbackController

  def oauth_access(conn, %{"code" => code}) do
    redirect_uri = to_string(conn.scheme) <> "s://" <> conn.host <> conn.request_path
    access_params = %{code: code,
                     client_id: Application.get_env(:dev3, :slack_client_id),
                     client_secret: Application.get_env(:dev3, :slack_client_secret),
                     redirect_uri: redirect_uri }

    with %{status_code: 200, body: body} <- request_access(access_params),
         {:ok, %{"ok" => true} = parsed_body} <- handle_json(body),
         data <- Map.take(parsed_body, @slack_fields) do
           Logger.debug("User info : #{inspect data}")
           redirect conn, to: github_authentication_path(conn, :oauth_access) 
         end
  end

  defp request_access(params) do
    HTTPoison.get!(@slack_oauth_access_url <> format_for_url(params))
  end

  defp handle_json(json) do
    {:ok, Poison.Parser.parse!(json)}
  end

  defp format_for_url(params) do
    Enum.reduce(params, "", fn({k, v}, acc) -> "#{acc}&#{k}=#{v}" end)
  end
end
