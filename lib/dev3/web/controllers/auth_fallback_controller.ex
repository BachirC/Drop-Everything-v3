defmodule Dev3.Web.AuthFallbackController do
  use Dev3.Web, :controller
  require Logger

  def call(conn, %{token: %{other_params: %{"error" => error}}}) do
    Logger.debug("GitHub OAuth error : #{error}")
    redirect(conn, to: "/dev3.html")
  end

  def call(conn, %{token: %{other_params: %{"ok" => false, "error" => error}}}) do
    Logger.debug("Slack OAuth error : #{error}")
    redirect(conn, to: "/dev3.html")
  end

  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    Logger.debug("Error on save: #{inspect changeset}")
    redirect(conn, to: "/dev3.html")
  end

  def call(conn, err) do
    Logger.debug("Error : #{inspect err}")
    redirect(conn, to: "/dev3.html")
  end
end
