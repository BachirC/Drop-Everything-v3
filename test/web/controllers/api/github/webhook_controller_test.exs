defmodule Dev3.Web.API.Slack.WebhookControllerTest do
  use Dev3.Web.ConnCase
  use ExUnit.Case, async: true
  import Dev3.Web.Router.Helpers

  @webhook_events Application.get_env(:dev3, GitHub)[:webhook_events]
  @message_types_by_action Application.get_env(:dev3, GitHub)[:message_types_by_action]

  test "halt connection when event not handled" do
    conn = build_conn()
           |> put_req_header("x-github-event", "unhandled_event")
           |> post(webhook_path(Dev3.Web.Endpoint, :webhook), [action: "handled_or_not"])

    assert conn.halted
    assert conn.status == Plug.Conn.Status.code(:ok)
  end

  test "halt connection when action not handled" do
    event = List.first(@webhook_events)
    conn = build_conn()
           |> put_req_header("x-github-event", to_string(event))
           |> post(webhook_path(Dev3.Web.Endpoint, :webhook), [action: "unhandled_action_for_sure"])

    assert conn.halted
    assert conn.status == Plug.Conn.Status.code(:ok)
  end

  test "Notify users when event/action handled" do
    {event, action} = @message_types_by_action
                      |> Map.keys()
                      |> List.first()

    conn = build_conn()
           |> put_req_header("x-github-event", to_string(event))
           |> post(webhook_path(Dev3.Web.Endpoint, :webhook), [action: action])

    refute conn.halted
    assert conn.status == Plug.Conn.Status.code(:ok)
  end
end
