defmodule Dev3.Web.AuthController do
  use Dev3.Web, :controller

  def index(conn, %{"provider" => provider}) do
    redirect conn, external: authorize_url!(provider)
  end

  def callback(conn, %{"provider" => provider, "code" => code}) do
    get_token!(conn, provider, code)
  end

  defp authorize_url!("github"), do: GitHub.authorize_url!
  defp authorize_url!(_), do: raise "Authorize : No matching provider available"

  defp get_token!(conn, "github", code) do
    GitHub.get_token!(code: code)
    redirect conn, to: "/"
  end

  defp get_token!(conn, "slack", code) do
    Slack.get_token!(code: code)
    redirect conn, to: auth_path(conn, :index, "github")
  end

  defp get_token!(_, _), do: raise "Token access : No matching provider available"
end
