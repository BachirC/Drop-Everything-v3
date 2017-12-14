defmodule Dev3.SlackMessenger.HTTPClient.ListreposResponse do
  @moduledoc """
    Defines the Slack response message for command /listrepos.
  """

  @behaviour Dev3.SlackMessenger.HTTPClient

  def build_message(data) do
    %{text: "", attachments: build_attachments(data)}
  end

  defp build_attachments(repos) do
    [%{
      title: """
        The following repos are currently being watched.
        To watch more, run `/watchrepos`
        To stop watching, run `/unwatchrepos`

      """,
      text: "· " <> Enum.join(repos, "\n· "),
      color: "#09c600"
    }]
  end
end
