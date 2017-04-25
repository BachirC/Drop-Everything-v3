defmodule Dev3.GitHubClient do
  @webhook_events ~w(pull_request pull_request_review pull_request_review_comment)

  @doc"""
    Create GitHub webhooks for the given repos.
  """
  def create_webhooks(%{github_access_token: access_token} = user, repos) do
    client = Tentacat.Client.new(%{access_token: access_token})
    user_repos = retrieve_user_repos(client, user, repos)
    user_repos_full_names = Enum.map(user_repos, fn repo -> repo.full_name end)

    repos_status = Enum.map(user_repos, &create_webhook(client, &1))
                   |> Enum.group_by(&List.first/1, &List.last/1)
                   |> Map.put(:not_found, repos -- user_repos_full_names)
    {:ok, repos_status}
  end

  defp retrieve_user_repos(client, user, repos) do
    case repos = Tentacat.Repositories.list_mine(client) do
      {200, _} -> Enum.filter_map(repos,
                                  fn repo -> Enum.member?(repos, repo["full_name"]) end,
                                  fn repo -> %{full_name: repo["full_name"],
                                               github_id: repo["id"],
                                               user_id:   user.id}
                                  end)
      {401, _} -> :unauthorized
    end
  end

  defp create_webhook(client, repo) do
    # TODO: Use path helper
    url = "https://022c031b.ngrok.io/api/github/webhook"
    body = [
      name: "web",
      active: true,
      events: @webhook_events,
      config: %{
        url: url,
        content_type: "json"
      }
    ]

    [owner, name] = String.split(repo.full_name, "/")
    response = Tentacat.Hooks.create(owner, name, body, client)

    case response do
      {201, _} -> [:created, repo]
      {422, %{"errors" => [%{"message" => msg}]}} -> [:noop, repo]
      {404, _} -> [:permission_error, repo]
      {_, _} -> [:unknown_error, repo]
    end
  end
end
