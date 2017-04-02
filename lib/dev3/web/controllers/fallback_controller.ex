defmodule Dev3.Web.FallbackController do
  use Dev3.Web, :controller
  require Logger

  def call(conn, {:ok, %{"error" => error, "ok" => false}}) do
    conn
    |> put_status(:unprocessable_entity)
    |> render(Dev3.Web.ErrorView, "slack_auth_error.json", %{error: error})
  end
end
