defmodule Dev3.Web.API.Slack.SlashCommandsFallbackController do
  use Dev3.Web, :controller

  require Logger

  def call(conn, {error, message}) do
    Logger.error fn -> "#{error} : #{message}" end
    send_resp(conn, 200, "")
  end

  def call(conn, %{"error" => error}) do
    Logger.error fn -> "Slack messenger error : #{error}" end
    send_resp(conn, 200, "")
  end

  def call(conn, error) do
    Logger.error fn -> "error : #{inspect error}" end
    send_resp(conn, 200, "")
  end
end
