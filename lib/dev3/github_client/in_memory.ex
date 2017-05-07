defmodule Dev3.GitHubClient.InMemory do
  @moduledoc """
    GitHubClient mock for tests.
  """

  @behaviour Dev3.GitHubClient

  def create_webhooks(user, _repos) do
    repos_status = %{created:      [%{full_name: "John/elixir-lang", github_id: 1, user_id: user.id}],
                     noop:         [%{full_name: "Sara/ex-http-client", github_id: 2, user_id: user.id}],
                     no_rights:    [%{full_name: "Org/private-repo" , github_id: 3, user_id: user.id}]}
    {:ok, repos_status}
  end
end
