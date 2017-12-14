defmodule Dev3.Web.RateLimit do
  @moduledoc """
    Defines logic for the API rate limit
  """

  import Phoenix.Controller, only: [json: 2]
  import Plug.Conn, only: [put_status: 2, halt: 1, send_resp: 3]

  def rate_limit(conn, options \\ []) do
    max_requests = options[:max_requests]


    case check_rate(conn, options) do
      {:ok, count} when count > max_requests -> alert_user(conn, options)
      {:ok, _count}                          -> conn
      {:error, _count}                       -> render_error(conn)
    end
  end

  defp check_rate(conn, options) do
    interval_ms = options[:interval_ms]
    max_requests = options[:ignore]
    ExRated.check_rate(bucket_name(conn), interval_ms, max_requests)
  end

  # Bucket name should be a combination of ip address (or user_id in our case) and request path, like so:
  # "user_id:/api/v1/authorizations"
  defp bucket_name(conn) do
    path = Enum.join(conn.path_info, "/")
    user_id = conn.assigns[:user].id
    "#{user_id}:#{path}"
  end

  defp alert_user(conn, options) do
    Dev3.Tasks.RateLimitAlertHandler.start(conn.assigns, options)
    conn |> send_resp(:ok, "") |> halt
  end

  defp render_error(conn) do
    conn |> send_resp(:ok, "") |> halt
  end
end
