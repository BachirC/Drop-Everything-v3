defmodule Dev3.SlackMessenger.WatchReposResponse do
  @statuses ~w(not_found permission_error noop created)a

  def build_attachments(data) do
    # To reorder the repos by status following @statuses order for better display
    @statuses -- (@statuses -- Map.keys(data))
    |> Enum.reduce([], fn(key, acc) -> if !Enum.empty?(repos = data[key]), do: [attachments(key, repos) | acc] end)
    |> Poison.encode!()
  end

  defp attachments(:not_found, repos) do
    %{
      "title": "These repos have not been found. Maybe a mistyping error ? :",
      "text": Enum.join(repos, ", "),
      "color": "#ef0e02"
    }
  end
  defp attachments(:permission_error, repos) do
    %{
      "title": "You don't have enough permission to add a webhook to the following repos. \
      Please contact an administrator to add automatically the webhook with DEv3 by issuing the same command or add the webhook manually to each repo : ",
      "text": Enum.map_join(repos, ", ", fn repo -> repo.full_name end),
      "color": "#ed8a00"
    }
  end
  defp attachments(:noop, repos) do
    %{
      "title": "Repos newly watched, a GitHub webhook already exists for the following repos :",
      "text": Enum.map_join(repos, ", ", fn repo -> repo.full_name end),
      "color": "#0000B7"
    }
  end
  defp attachments(:created, repos) do
    %{
      "title": "Repos newly watched, a GitHub webhook pointing to DEv3 has been added to the following repos :",
      "text": Enum.map_join(repos, ", ", fn repo -> repo.full_name end),
      "color": "#09c600"
    }
  end
end
