defmodule Dev3.SlackMessenger.HTTPClient.ReviewRequested do
  @moduledoc """
    Defines the Slack message sent to a user when requested as reviewer for a pull request
  """

  @behaviour Dev3.SlackMessenger.HTTPClient

  def build_message(data) do
   %{text: "", attachments: build_attachments(data)}
  end

  defp build_attachments(data) do
    [%{
      title: "Review requested · Pull request ##{data.issue.number} · #{data.issue.title} · #{data.branches.head} -> #{data.branches.base}",
      title_link: data.issue.url,
      author_name: data.sender.name,
      author_icon: data.sender.avatar_url,
      footer: data.repo.name,
      footer_icon: data.owner.avatar_url,
      color: "#81adf4"
    }]
  end
end
