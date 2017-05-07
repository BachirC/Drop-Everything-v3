defmodule Dev3.Web.API.Slack.SlashCommandsFallbackController do
  use Dev3.Web, :controller

  require Logger

  def call(conn, {error, message}) do
    Logger.debug fn -> "#{error} : #{message}" end
    send_resp(conn, 200, "")
  end

  def call(conn, %{"error" => error}) do
    Logger.debug fn -> "Slack messenger error : #{error}" end
    send_resp(conn, 200, "Slack Messenger error")
  end

  def call(conn, error) do
    Logger.debug fn -> "error : #{inspect error}" end
    send_resp(conn, 200, "Unexpected error")
  end
end
