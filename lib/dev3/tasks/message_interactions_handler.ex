defmodule Dev3.Task.MessageInteractionsHandler do
  @moduledoc false

  alias Dev3.SlackMessenger.MessageInteractionsParser
  @slack_messenger Application.get_env(:dev3, :slack_messenger)

  def start(params) do
    Task.Supervisor.start_child(Dev3.TaskSupervisor, fn -> perform(params) end)
  end

  def perform(%{params: params, user: user} = _params) do
    params["actions"]
    |> List.first()
    |> Map.get("name")
    |> String.to_atom()
    |> MessageInteractionsParser.parse(user, params)
    |> @slack_messenger.update_message(user)
  end
end
