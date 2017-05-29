defmodule Dev3.Web.API.Slack.MessageInteractionsController do
  use Dev3.Web, :controller
  alias Dev3.User

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
      conn |> send_resp(:ok, "Invalid token") |> halt
    end
  end

  defp assign_user(%{assigns: %{params: %{"team" => team, "user" => slack_user}}} = conn, _) do
    if user = User.retrieve_with_slack(%{slack_team_id: team["id"], slack_user_id: slack_user["id"]}) do
      conn |> assign(:user, user)
    else
      conn |> send_resp(:ok, "User not found") |> halt
    end
  end
  defp assign_user(conn, _) do
    conn |> send_resp(:ok, "User not found") |> halt
  end
end
