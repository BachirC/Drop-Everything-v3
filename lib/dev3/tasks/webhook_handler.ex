defmodule Dev3.Tasks.WebhookHandler do
  @moduledoc false

  @slack_messenger Application.get_env(:dev3, :slack_messenger)
  @webhook_parser Application.get_env(:dev3, :webhook_parser)

  def start(message_type, params) do
    Task.Supervisor.start_child(Dev3.TaskSupervisor, fn -> perform(message_type, params) end)
  end

  defp perform(message_type, params) do
    {:ok, users, message_params} = @webhook_parser.parse(message_type, params)
    Enum.each(users, fn user -> @slack_messenger.notify(message_type, user, message_params) end)
  end
end
