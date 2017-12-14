defmodule Dev3.Web.API.GitHub.WebhookController do
  use Dev3.Web, :controller
  require Logger

  action_fallback Dev3.Web.API.GitHub.WebhookFallbackController

  plug :dispatch_by_action

  @message_types_by_action Application.get_env(:dev3, GitHub)[:message_types_by_action]

  def webhook(%{assigns: %{message_types: message_types}} = conn, params) do
    message_types
    |> Enum.each(fn message_type -> Dev3.Tasks.WebhookHandler.start(message_type, params) end)
    send_resp(conn, :ok, "")
  end

  defp dispatch_by_action(conn, _) do
    event = conn
            |> get_req_header("x-github-event")
            |> Enum.fetch!(0)
    action = conn.params["action"]
    message_types = @message_types_by_action[{event, action}]

    if message_types do
      conn |> assign(:message_types, message_types)
    else
      conn |> send_resp(:ok, "") |> halt
    end
  end
end
