defmodule Dev3.GitHubClient do
  require Logger

  def watch_repos(%{github_access_token: access_token} = user, repos) do
    client = Tentacat.Client.new(%{access_token: access_token})
    user_repos = retrieve_user_repos(client, repos)
    user_repos_full_names = Enum.map(user_repos, fn repo -> repo.full_name end)

    repos_status = Enum.map(user_repos, &create_webhook(client, &1))
                   |> Enum.group_by(&List.first/1, &List.last/1)
                   |> Map.put(:not_found, repos -- user_repos_full_names)
    Logger.warn("Repos : #{inspect repos_status}")
    {:ok, repos_status}
  end

  defp retrieve_user_repos(client, repos) do
    Tentacat.Repositories.list_mine(client)
    |> Enum.filter_map(fn repo -> Enum.member?(repos, repo["full_name"]) end,
                       fn repo -> %{full_name: repo["full_name"],
                                    name: repo["name"],
                                    owner: repo["owner"]["login"]} end)
  end

  defp create_webhook(client, repo) do
    # TODO: Use path helper
    url = "https://022c031b.ngrok.io/api/github/webhook"
    body = [
      name: "web",
      active: true,
      events: [
        "pull_request",
        "pull_request_review",
        "pull_request_review_comment"
      ],
      config: %{
        url: url,
        content_type: "json"
      }
    ]

    response = Tentacat.Hooks.create(repo.owner, repo.name, body, client)
    already_exists_error_msg = ~s(Hook already exists on this repository)

    case response do
      {201, _} -> [:created, repo.full_name]
      {422, %{"errors" => [%{"message" => already_exists_error_msg}]}} -> [:noop, repo.full_name]
      {404, _} -> [:permission_error, repo.full_name]
      {_} -> [:unknown_error, repo.full_name]
    end
  end
end
