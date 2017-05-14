defmodule Dev3.Web.API.GitHub.WebhookFallbackController do
  use Dev3.Web, :controller
  require Logger

  def call(conn, {:invalid_event, event}) do
    Logger.debug fn -> "Error in webhook controller : Invalid event #{inspect event}" end
    conn |> send_resp(:ok, ~s(Event "#{event}" not supported)) |> halt
  end

  def call(conn, error) do
    Logger.debug fn -> "Unexpected error in webhook controller : #{inspect error}" end
    conn |> send_resp(:ok, ~s(Unexpected error)) |> halt
  end
end
