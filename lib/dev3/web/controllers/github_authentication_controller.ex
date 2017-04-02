defmodule Dev3.Web.GithubAuthenticationController do
  use Dev3.Web, :controller

  require Logger

  plug :put_view, Dev3.Web.GithubHookView

  action_fallback Dev3.Web.FallbackController

  def oauth_access(conn, _params) do
    render conn, "200.json"
  end
end
