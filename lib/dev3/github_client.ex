defmodule Dev3.GitHubClient do
  @webhook_events ~w(pull_request pull_request_review pull_request_review_comment)

  @doc"""
    Create GitHub webhooks for the given repos.
  """
  def create_webhooks(%{github_access_token: access_token} = user, repos) do
    client = Tentacat.Client.new(%{access_token: access_token})
    [_ | _] = (user_repos = retrieve_user_repos(client, user, repos))

    repos_status = Enum.map(user_repos, &create_webhook(client, &1))
                   |> Enum.group_by(&List.first/1, &List.last/1)
    {:ok, repos_status}
  end

  defp retrieve_user_repos(client, user, repos) do
    case fetched_repos = Tentacat.Repositories.list_mine(client) do
      [_ | _]      -> Enum.filter_map(fetched_repos,
                                  fn repo -> Enum.member?(repos, repo["full_name"]) end,
                                  fn repo -> %{full_name: repo["full_name"],
                                               github_id: repo["id"],
                                               user_id:   user.id}
                                  end)
      {401, _} -> {:error, "Error while retrieving GitHub repos : Bad credentials"}
    end
  end

  defp create_webhook(client, repo) do
    # TODO: Use path helper
    url = "https://fcc16f32.ngrok.io/api/github/webhook"
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

    case Tentacat.Hooks.create(owner, name, body, client) do
      {201, _} -> [:created, repo]
      {422, %{"errors" => [%{"message" => msg}]}} -> [:noop, repo]
      {404, _} -> [:no_rights, repo]
      {_, _} -> [:unknown_error, repo]
    end
  end
end
