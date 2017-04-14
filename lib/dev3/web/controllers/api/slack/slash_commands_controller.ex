defmodule Dev3.Web.API.Slack.SlashCommandsController do
  use Dev3.Web, :controller

  def watch_repos(conn, params) do
    send_resp(conn, 200, "")
  end
end
