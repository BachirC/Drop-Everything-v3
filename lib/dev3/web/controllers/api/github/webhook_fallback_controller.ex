defmodule Dev3.Web.API.GitHub.WebhookFallbackController do
  use Dev3.Web, :controller
  require Logger

  def call(conn, {:invalid_event, event}) do
    Logger.error fn -> "Error in webhook controller : Invalid event #{inspect event}" end
    conn |> send_resp(:ok, "") |> halt
  end

  def call(conn, error) do
    Logger.error fn -> "Unexpected error in webhook controller : #{inspect error}" end
    conn |> send_resp(:ok, "") |> halt
  end
end
