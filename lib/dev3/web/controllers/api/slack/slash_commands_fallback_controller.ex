defmodule Dev3.Web.API.Slack.SlashCommandsFallbackController do
  use Dev3.Web, :controller

  require Logger

  def call(conn, {error, message}) do
    Logger.debug("#{error} : #{message}")
    send_resp(conn, 200, "")
  end

  def call(conn, %{"error" => error}) do
    Logger.debug("Slack messenger error : #{error}")
    send_resp(conn, 200, "")
  end
end
