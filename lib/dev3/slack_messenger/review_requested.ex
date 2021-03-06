defmodule Dev3.SlackMessenger.HTTPClient.ReviewRequested do
  @moduledoc """
    Defines the Slack message sent to a user when requested as reviewer for a pull request
  """

  @behaviour Dev3.SlackMessenger.HTTPClient

  import Dev3.SlackMessenger.MessageBuilder

  def build_message(data) do
   %{text: "", attachments: build_attachments(data)}
  end

  defp build_attachments(data) do
    attachment = data
                 |> base_attachment()
                 |> add_action(:snooze, data)
                 |> add_action(:mute_issue, data)

    [attachment]
  end

  defp base_attachment(data) do
    %{title: ":memo: Review requested · Pull request ##{data.issue.number} · #{data.issue.title} · #{data.branches.head} -> #{data.branches.base}",
     title_link: data.issue.url,
     author_name: data.sender.name,
     author_icon: data.sender.avatar_url,
     footer: data.repo.name,
     footer_icon: data.repo.owner.avatar_url,
     color: "#81adf4",
     callback_id: "issue_actions",
     actions: []}
  end
end
