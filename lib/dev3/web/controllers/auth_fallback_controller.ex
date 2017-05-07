defmodule Dev3.Web.AuthFallbackController do
  use Dev3.Web, :controller
  require Logger

  def call(conn, %{token: %{other_params: %{"error" => error}}}) do
    Logger.debug fn -> "GitHub OAuth error : #{error}" end
    redirect(conn, to: "/dev3.html")
  end

  def call(conn, %{token: %{other_params: %{"ok" => false, "error" => error}}}) do
    Logger.debug fn -> "Slack OAuth error : #{error}" end
    redirect(conn, to: "/dev3.html")
  end

  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    Logger.debug fn -> "Error on save: #{inspect changeset}" end
    redirect(conn, to: "/dev3.html")
  end

  def call(conn, err) do
    Logger.debug fn -> "Error : #{inspect err}" end
    redirect(conn, to: "/dev3.html")
  end
end
