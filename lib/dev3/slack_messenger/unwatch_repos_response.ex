defmodule Dev3.SlackMessenger.UnwatchReposResponse do
  @statuses ~w(not_found unwatched)a

  def build_attachments(data) do
    # To reorder the repos by status following @statuses order for better display
    res = @statuses -- (@statuses -- Map.keys(data))
    |> Enum.reduce([], fn(key, acc) ->
      if !Enum.empty?(repos = data[key]), do: [attachments(key, repos) | acc], else: acc
      end)
    |> Poison.encode!()
  end

  defp attachments(:unwatched, repos) do
    %{
      "title": """
        The following repos have been unwatched. You will no longer receive messages\
        related to them. To watch again, run `/watchrepos`
      """,
      "text": "• " <> Enum.join(repos, "\n• "),
      "color": "#09c600"
    }
  end
  defp attachments(:not_found, repos) do
    %{
      "title": "These repos are not being watched or have not been found",
      "text": "• " <> Enum.join(repos, "\n• "),
      "color": "#ef0e02"
    }
  end
end
