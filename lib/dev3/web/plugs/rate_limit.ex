defmodule Dev3.Web.RateLimit do
  import Phoenix.Controller, only: [json: 2]
  import Plug.Conn, only: [put_status: 2, halt: 1, send_resp: 3]

  @slack_messenger Application.get_env(:dev3, :slack_messenger)

  def rate_limit(conn, options \\ []) do
    max_requests = options[:max_requests]
    case check_rate(conn, options) do
      {:ok, count} when count > max_requests -> alert_user(conn, options)
      {:ok, _count}                          -> conn
      {:error, _count}                        -> render_error(conn)
    end
  end

  defp check_rate(conn, options) do
    interval_milliseconds = options[:interval_seconds] * 1000
    max_requests = options[:ignore]
    ExRated.check_rate(bucket_name(conn), interval_milliseconds, max_requests)
  end

  # Bucket name should be a combination of ip address (or user_id in our case) and request path, like so:
  # "user_id:/api/v1/authorizations"
  defp bucket_name(conn) do
    path = Enum.join(conn.path_info, "/")
    #ip   = conn.remote_ip |> Tuple.to_list |> Enum.join(".")
    user_id = conn.assigns[:user].id
    "#{user_id}:#{path}"
  end

  defp alert_user(conn, options) do
    @slack_messenger.notify(:rate_limit_exceeded, conn.assigns[:user], options)
    conn |> send_resp(:ok, "Rate limit exceeded") |> halt
  end

  defp render_error(conn) do
    conn
    |> put_status(:too_many_requests)
    |> json(%{error: "Rate limit exceeded"})
    |> halt
  end
end
