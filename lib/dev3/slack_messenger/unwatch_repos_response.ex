defmodule Dev3.SlackMessenger.HTTPClient.UnwatchReposResponse do
  @moduledoc """
    Defines the Slack response message attachments for command /unwachrepos.
  """

  @behaviour Dev3.SlackMessenger.HTTPClient

  @statuses ~w(not_found unwatched)a

  def build_attachments(data) do
    # To reorder the repos by status following @statuses order for better display
    @statuses -- (@statuses -- Map.keys(data))
    |> Enum.reduce([], fn(key, acc) ->
      if Enum.empty?(data[key]), do: acc, else: [attachments(key, data[key]) | acc]
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
