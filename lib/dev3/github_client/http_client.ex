defmodule Dev3.GitHubClient.HTTPClient do
  @moduledoc false

  @behaviour Dev3.GitHubClient

  @webhook_events Application.get_env(:dev3, GitHub)[:webhook_events]

  @doc false
  def create_webhooks(%{github_access_token: access_token} = user, repos) do
    client = Tentacat.Client.new(%{access_token: access_token})
    user_repos = retrieve_user_repos(client, user, repos)
    repos_status = case user_repos do
      []      -> %{}
      [_ | _] -> user_repos
                 |> Enum.map(&create_webhook(client, &1))
                 |> Enum.group_by(&List.first/1, &List.last/1)
    end

    {:ok, repos_status}
  end

  defp retrieve_user_repos(client, user, repos) do
    case fetched_repos = Tentacat.Repositories.list_mine(client) do
      [_ | _]  -> Enum.filter_map(fetched_repos,
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
    url = "#{Dev3.Web.Router.Helpers.url(Dev3.Web.Endpoint)}/api/github/webhook"
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
