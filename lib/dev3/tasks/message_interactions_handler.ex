defmodule Dev3.Task.MessageInteractionsHandler do
  @moduledoc false
  @action_types ~w(mute_issue unmute_issue snooze)a
  @slack_messenger Application.get_env(:dev3, :slack_messenger)

  alias Dev3.Workers.SnoozedMessagesSender
  alias Dev3.SlackMessenger.MessageInteractionsParser

  def start(action_type, params) when action_type in @action_types do
    Task.Supervisor.start_child(Dev3.TaskSupervisor, fn -> perform(action_type, params) end)
  end

  def perform(:snooze = action, %{params: params, user: user}) do
    %{attachments: attachments, snooze_duration: snooze_duration} = MessageInteractionsParser.parse(action, user, params)
    {:ok, _ack} = Exq.Enqueuer.enqueue_in(Exq,
                                         "slack_messages",
                                         snooze_duration,
                                         SnoozedMessagesSender,
                                         [user.id, Poison.encode!(attachments)])
  end
  def perform(action, %{params: params, user: user}) do
    action
    |> MessageInteractionsParser.parse(user, params)
    |> @slack_messenger.update(user)
  end
end
