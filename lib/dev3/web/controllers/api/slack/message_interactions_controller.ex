defmodule Dev3.Web.API.Slack.MessageInteractionsController do
  use Dev3.Web, :controller
  alias Dev3.User
  require Logger

  plug :parse_params
  plug :verify_token
  plug :assign_user

  def message_interaction(%{assigns: assigns} = conn, _params) do
    action_type = assigns.params["actions"]
                  |> List.first()
                  |> Map.get("name")
                  |> String.to_atom()

    Dev3.Task.MessageInteractionsHandler.start(action_type, assigns)
    send_resp(conn, :ok, "")
  end

  defp parse_params(%{params: %{"payload" => payload}} = conn, _) do
    assign(conn, :params, Poison.decode!(payload))
  end

  defp verify_token(conn, _) do
    if conn.assigns[:params]["token"] == Application.get_env(:dev3, Slack)[:verification_token] do
      conn
    else
      body = conn.assigns.params
      action = body["actions"] |> List.first() |> Map.get("name")
      Logger.error fn -> "[MessageInteractions.InvalidSlackVerificationTokenError \
action=#{action} slack_user_id=#{body["user"]["id"]} slack_team_id=#{body["team"]["id"]}] Invalid verification token" end
      conn |> send_resp(:ok, "") |> halt
    end
  end

  defp assign_user(%{assigns: %{params: %{"team" => team, "user" => slack_user}}} = conn, _) do
    if user = User.retrieve_with_slack(%{slack_team_id: team["id"], slack_user_id: slack_user["id"]}) do
      conn |> assign(:user, user)
    else
      Logger.error fn -> "[MessageInteractions.SlackUserNotFoundError slack_user_id=#{slack_user["id"]} \
slack_team_id=#{team["id"]}] User not found" end
      conn |> send_resp(:ok, "") |> halt
    end
  end
  defp assign_user(conn, _) do
    Logger.error fn -> "[MessageInteractions.SlackUserNotFoundError] User not found" end
    conn |> send_resp(:ok, "") |> halt
  end
end
