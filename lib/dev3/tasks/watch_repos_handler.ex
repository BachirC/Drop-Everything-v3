defmodule Dev3.Tasks.WatchReposHandler do
  @moduledoc false

  @github_client   Application.get_env(:dev3, :github_client)
  @slack_messenger Application.get_env(:dev3, :slack_messenger)

  alias Dev3.GitHub.WatchedRepo

  def start(params) do
    Task.Supervisor.start_child(Dev3.TaskSupervisor, fn -> perform(params) end)
  end

  defp perform(%{user: user, args: args}) do
    {:ok, repos_status} = @github_client.create_webhooks(user, args)

    valid_repos = listify(repos_status)
    {_, nil} = WatchedRepo.insert_watched(valid_repos)

    repos_names = for {k, v} <- repos_status, into: %{}, do: {k, Enum.map(v, fn repo -> repo.full_name end)}
    # Somehow, piping directly on the comprehension has unexpected results
    repos_names = repos_names |> Map.put(:not_found, args -- Enum.map(valid_repos, fn repo -> repo.full_name end))
    :ok = @slack_messenger.notify(:watch_repos_response, user, repos_names)
  end

  defp listify(map), do: map |> Map.values() |> List.flatten()
end
