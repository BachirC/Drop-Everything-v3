defmodule Dev3.Web.AuthFallbackController do
  use Dev3.Web, :controller
  require Logger

  def call(conn, %{token: %{other_params: %{"error" => error}}}) do
    Logger.error fn -> "GitHub OAuth error : #{error}" end
    redirect(conn, to: "/dev3.html")
  end

  def call(conn, %{token: %{other_params: %{"ok" => false, "error" => error}}}) do
    Logger.error fn -> "Slack OAuth error : #{error}" end
    redirect(conn, to: "/dev3.html")
  end

  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    Logger.error fn -> "Error on save: #{inspect changeset}" end
    redirect(conn, to: "/dev3.html")
  end

  def call(conn, err) do
    Logger.error fn -> "Error : #{inspect err}" end
    redirect(conn, to: "/dev3.html")
  end
end
