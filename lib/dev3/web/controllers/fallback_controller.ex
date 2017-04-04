defmodule Dev3.Web.FallbackController do
  use Dev3.Web, :controller
  require Logger

  @doc """
  Handles Github OAuth errors
  """
  def call(conn, {:ok, %{"error_description" => error}}) do
    conn
    |> put_status(:unprocessable_entity)
    |> render(Dev3.Web.ErrorView, "slack_auth_error.json", %{error: error})
  end

  @doc """
  Handles Slack OAuth errors
  """
  def call(conn, {:ok, %{"error" => error, "ok" => false}}) do
    conn
    |> put_status(:unprocessable_entity)
    |> render(Dev3.Web.ErrorView, "slack_auth_error.json", %{error: error})
  end

  @doc """
  Handles Github API bad credentials error
  """
  def call(conn, %{status_code: 401}) do
    conn
    |> put_status(:unauthorized)
    |> render(Dev3.Web.ErrorView, "401.json")
  end
end
