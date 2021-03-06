defmodule Dev3.SlackMessenger.HTTPClient.NotifyOwnerOnIssueComment do
  @moduledoc "Defines the Slack message sent to a user when tagged in an issue comment"

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
    %{title: ":speech_balloon: New comment · #{humanize(data.issue.type)} ##{data.issue.number} · #{data.issue.title}",
     title_link: data.comment.url,
     author_name: data.sender.name,
     author_icon: data.sender.avatar_url,
     footer: data.repo.name,
     footer_icon: data.repo.owner.avatar_url,
     color: "#a7c7f9",
     callback_id: "issue_actions",
     actions: []}
  end
end

