defmodule Dev3.Web.API.GitHub.WebhookController do
  use Dev3.Web, :controller

  action_fallback Dev3.Web.API.GitHub.WebhookFallbackController

  plug :dispatch_by_action

  @message_type_by_action Application.get_env(:dev3, GitHub)[:message_type_by_action]

  def webhook(%{assigns: %{message_type: message_type}} = conn, params) do
    Dev3.Tasks.WebhookHandler.start(message_type, params)
    send_resp(conn, :ok, "Messages sent !")
  end

  defp dispatch_by_action(conn, _) do
    event = conn
            |> get_req_header("x-github-event")
            |> Enum.fetch!(0)
    action = conn.params["action"]
    message_type = @message_type_by_action[{event, action}]

    if message_type do
      conn |> assign(:message_type, message_type)
    else
      conn |> send_resp(:ok, "Invalid {event: '#{event}', action: '#{action}'}") |> halt
    end
  end
end
