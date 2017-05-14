defmodule Dev3.Web.API.Slack.WebhookControllerTest do
  use Dev3.Web.ConnCase
  import Dev3.Web.Router.Helpers
  alias Dev3.Repo
  alias Dev3.User
  alias Dev3.GitHub.WatchedRepo

  @webhook_events Application.get_env(:dev3, GitHub)[:webhook_events]
  @message_type_by_action Application.get_env(:dev3, GitHub)[:message_type_by_action]

  test "halt connection when event not handled" do
    conn = build_conn()
           |> put_req_header("x-github-event", "unhandled_event")
           |> post(webhook_path(Dev3.Web.Endpoint, :webhook), [action: "handled_or_not"])

    assert conn.halted
    assert conn.status == Plug.Conn.Status.code(:ok)
    assert conn.resp_body == "Invalid {event: 'unhandled_event', action: 'handled_or_not'}"
  end

  test "halt connection when action not handled" do
    event = List.first(@webhook_events)
    conn = build_conn()
           |> put_req_header("x-github-event", to_string(event))
           |> post(webhook_path(Dev3.Web.Endpoint, :webhook), [action: "unhandled_action_for_sure"])

    assert conn.halted
    assert conn.status == Plug.Conn.Status.code(:ok)
    assert conn.resp_body == "Invalid {event: '#{event}', action: 'unhandled_action_for_sure'}"
  end

  test "Notify users when event/action handled" do
    {event, action} = @message_type_by_action
                      |> Map.keys()
                      |> List.first()

    conn = build_conn()
           |> put_req_header("x-github-event", to_string(event))
           |> post(webhook_path(Dev3.Web.Endpoint, :webhook), [action: action])

    refute conn.halted
    assert conn.status == Plug.Conn.Status.code(:ok)
    assert conn.resp_body == "Messages sent !"
  end
end
