defmodule Dev3.Web.API.GitHub.GitHubController do
  use Dev3.Web, :controller

  def webhook(conn, params) do
    send_resp(conn, 200, "")
  end
end
