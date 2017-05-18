defmodule Dev3.Tasks.UnwatchReposHandler do
  @moduledoc false

  @slack_messenger Application.get_env(:dev3, :slack_messenger)

  alias Dev3.GitHub.WatchedRepo

  def start(params) do
    Task.Supervisor.start_child(Dev3.TaskSupervisor, fn -> perform(params) end)
  end

  defp perform(%{user: user, args: args}) do
    watched_repos = Enum.map(WatchedRepo.list(user), fn x -> x.full_name end)
    repos_not_found = args -- watched_repos
    repos_status = %{unwatched: args -- repos_not_found, not_found: repos_not_found}

    {_, nil} = WatchedRepo.delete_unwatched(user, args)
    :ok = @slack_messenger.notify(:unwatch_repos_response, user, repos_status)
  end
end
