defmodule Dev3.Tasks.RateLimitAlertHandler do
  @moduledoc false

  @slack_messenger Application.get_env(:dev3, :slack_messenger)

  def start(params, options) do
    Task.Supervisor.start_child(Dev3.TaskSupervisor, fn -> perform(params, options) end)
  end

  defp perform(params, options) do
    @slack_messenger.notify(:rate_limit_exceeded, params.user, options)
  end
end
