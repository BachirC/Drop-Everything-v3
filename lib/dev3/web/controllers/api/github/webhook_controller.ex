defmodule Dev3.Web.API.GitHub.WebhookController do
  use Dev3.Web, :controller
  alias Dev3.GitHub.WebhookParser

  action_fallback Dev3.Web.API.GitHub.WebhookFallbackController

  plug :dispatch_by_action

  @slack_messenger Application.get_env(:dev3, :slack_messenger)
  @webhook_parser Application.get_env(:dev3, :webhook_parser)
  @message_type_by_action Application.get_env(:dev3, GitHub)[:message_type_by_action]

  def webhook(%{assigns: %{message_type: message_type}} = conn, params) do
    with {:ok, users, message_params} <- @webhook_parser.parse(message_type, params) do
      Enum.each(users, fn user -> @slack_messenger.notify(message_type, user, message_params) end)
      send_resp(conn, :ok, "Messages sent !")
    end
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
