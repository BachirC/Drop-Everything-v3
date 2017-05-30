defmodule Dev3.Web.OAuth.Slack do
  @moduledoc """
  An OAuth2 strategy for GitHub.
  """
  use OAuth2.Strategy

  alias OAuth2.Strategy.AuthCode

  defp config do
    [strategy: __MODULE__,
     site: "https://api.slack.com",
     authorize_url: "https://slack.com/oauth/authorize",
     token_url: "https://slack.com/api/oauth.access"]
  end

  # Public API

  @doc"""
    OAuth client for Github.
  """
  def client do
    :dev3
    |> Application.get_env(Slack)
    |> Keyword.merge(config())
    |> OAuth2.Client.new()
  end

  @doc"""
    Initiates the request to /oauth/oauth.acess to retrieve the token for the user.
  """
  def get_token!(params \\ [], headers \\ []) do
    OAuth2.Client.get_token!(client(), Keyword.merge(params, client_secret: client().client_secret))
  end

  # Strategy Callbacks

  def get_token(client, params, headers) do
    client
    |> put_header("Accept", "application/json")
    |> AuthCode.get_token(params, headers)
  end
end
