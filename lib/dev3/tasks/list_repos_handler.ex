defmodule Dev3.Tasks.ListReposHandler do
  @moduledoc false

  @slack_messenger Application.get_env(:dev3, :slack_messenger)

  alias Dev3.GitHub.WatchedRepo

  def start(params) do
    Task.Supervisor.start_child(Dev3.TaskSupervisor, fn -> perform(params) end)
  end

  defp perform(%{user: user}) do
    watched_repos = Enum.map(WatchedRepo.list(user), fn x -> x.full_name end)
    :ok = @slack_messenger.notify(:listrepos_response, user, watched_repos)
  end
end
