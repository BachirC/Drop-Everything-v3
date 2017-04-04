defmodule Dev3.Web.GithubAuthorizationController do
  use Dev3.Web, :controller

  require Logger

  plug :put_view, Dev3.Web.GithubHookView

  @oauth_authorize_url ~s(https://github.com/login/oauth/authorize)
  @oauth_access_url ~s(https://github.com/login/oauth/access_token)
  @github_api_host ~s(https://api.github.com)
  @permissions_scope ~s(write:repo_hook)

  action_fallback Dev3.Web.FallbackController

  def authorize(conn, params) do
    redirect_uri = Enum.join([to_string(conn.scheme),
                             "s://",
                             conn.host,
                             github_authorization_path(Dev3.Web.Endpoint, :oauth_access)])
    Logger.debug("Redirect URI : #{redirect_uri}")
    authorization_params = %{redirect_uri: redirect_uri,
                             scope: @permissions_scope,
                             client_id: Application.get_env(:dev3, :github_client_id)}
    redirect conn, external: @oauth_authorize_url <> "?" <> format_for_url(authorization_params)
  end

  def oauth_access(conn, %{"code" => code}) do
    redirect_uri = Enum.join([to_string(conn.scheme),
                             "s://",
                             conn.host,
                             github_authorization_path(Dev3.Web.Endpoint, :oauth_access)])
    access_params = %{code: code,
                     client_id: Application.get_env(:dev3, :github_client_id),
                     client_secret: Application.get_env(:dev3, :github_client_secret),
                     redirect_uri: redirect_uri}
    with %{status_code: 200, body: body} <- request_access(access_params),
         {:ok, %{"access_token" => access_token} = parsed_body} <- handle_json(body),
         %{status_code: 200, body: body} <- get_user_info(access_token),
         {:ok, %{"login" => github_login} = parsed_body} <- handle_json(body) do
           Logger.debug("Github User info : #{inspect parsed_body}")
           redirect conn, to: "/"
         end
  end

  defp get_user_info(access_token) do
    headers = ["Accept": "application/vnd.github.v3+json",
               "Authorization": "Bearer " <> access_token]
    s = HTTPoison.get!(@github_api_host <> "/user", headers)
    Logger.debug "Get user info: #{inspect s}"
    s
  end

  defp request_access(params) do
    headers = ["Accept": "application/json"]
    s = HTTPoison.get!(@oauth_access_url <> "?" <> format_for_url(params), headers)
    Logger.debug "Request Access : #{inspect s}"
    s
  end

  defp handle_json(json) do
    Logger.warn "JSON : #{inspect json}"
    {:ok, Poison.Parser.parse!(json)}
  end

  defp format_for_url(params) do
    Enum.reduce(params, "", fn({k, v}, acc) -> "#{acc}&#{k}=#{v}" end)
  end
end
