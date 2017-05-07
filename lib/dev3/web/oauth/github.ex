defmodule GitHub do
  @moduledoc """
  An OAuth2 strategy for GitHub.
  """
  use OAuth2.Strategy

  alias OAuth2.Strategy.AuthCode

  defp config do
    [strategy: __MODULE__,
     site: "https://api.github.com",
     authorize_url: "https://github.com/login/oauth/authorize",
     token_url: "https://github.com/login/oauth/access_token"]
  end

  # Public API

  @doc"""
    OAuth client for Github.
  """
  def client do
    :dev3
    |> Application.get_env(GitHub)
    |> Keyword.merge(config())
    |> OAuth2.Client.new()
  end

  @doc"""
    Initiates the request to /oauth/authorize that redirects to the callback URL.
  """
  def authorize_url!(params \\ []) do
    OAuth2.Client.authorize_url!(client(), Keyword.merge(params, scope: Application.get_env(:dev3, GitHub)[:scope]))
  end

  @doc"""
    Initiates the request to /oauth/access_token to retrieve the token for the user.
  """
  def get_token!(params \\ [], headers \\ []) do
    OAuth2.Client.get_token!(client(), Keyword.merge(params, client_secret: client().client_secret))
  end

  @doc"""
    Gets github user info.
  """
  def get_user!(client) do
    %{token: %{access_token: token}} = client
    %{body: %{"login" => user_id}} = OAuth2.Client.get!(client, "/user")
    %{access_token: token, user_id: user_id}
  end

  # Strategy Callbacks

  def authorize_url(client, params) do
    AuthCode.authorize_url(client, params)
  end

  def get_token(client, params, headers) do
    client
    |> put_header("Accept", "application/json")
    |> AuthCode.get_token(params, headers)
  end
end
