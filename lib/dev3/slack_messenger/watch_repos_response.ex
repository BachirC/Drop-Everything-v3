defmodule Dev3.SlackMessenger.HTTPClient.WatchReposResponse do
  @moduledoc """
    Defines the Slack response message attachments for command /wachrepos.
  """

  @behaviour Dev3.SlackMessenger.HTTPClient

  @statuses ~w(not_found no_rights noop created)a

  def build_attachments(data) do
    # To reorder the repos by status following @statuses order for better display
    @statuses -- (@statuses -- Map.keys(data))
    |> Enum.reduce([], fn(key, acc) ->
      if Enum.empty?(data[key]), do: acc, else: [attachments(key, data[key]) | acc]
      end)
    |> Poison.encode!()
  end

  defp attachments(:not_found, repos) do
    %{
      "title": """
       These repos have not been found. Either it's a mistyping error or these repos are\
       private and you need to give DEv3 access to them\
       https://help.github.com/articles/requesting-organization-approval-for-your-authorized-applications
      """,
      "text": "• " <> Enum.join(repos, "\n• "),
      "color": "#ef0e02"
    }
  end
  # TODO: Add link to "How to add DEv3 webhook on GitHub"
  defp attachments(:no_rights, repos) do
    %{
      "title": """
       Repos newly watched, you don't have enough permissions to add a webhook to the following repos.
       To start receiving messages for these repos, make sure a GitHub webhook is set for DEv3\
       (How to add DEv3 webhook on GitHub)
      """,
      "text": "• " <> Enum.join(repos, "\n• "),
      "color": "#ed8a00"
    }
  end
  defp attachments(:noop, repos) do
    %{
      "title": "Repos newly watched, a GitHub webhook already exists for the following repos",
      "text": "• " <> Enum.join(repos, "\n• "),
      "color": "#0000B7"
    }
  end
  defp attachments(:created, repos) do
    %{
      "title": "Repos newly watched, a GitHub webhook pointing to DEv3 has been added to the following repos",
      "text": "• " <> Enum.join(repos, "\n• "),
      "color": "#09c600"
    }
  end
end
