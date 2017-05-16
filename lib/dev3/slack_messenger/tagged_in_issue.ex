defmodule Dev3.SlackMessenger.HTTPClient.TaggedInIssue do
  @moduledoc "Defines the Slack message sent to a user when tagged in an issue comment"

  @behaviour Dev3.SlackMessenger.HTTPClient

  def build_message(data) do
    %{text: "", attachments: build_attachments(data)}
  end

  defp build_attachments(data) do
    [%{
      title: "You have been mentioned · #{humanize(data.issue.type)} ##{data.issue.number} · #{data.issue.title}",
      title_link: data.issue.url,
      author_name: data.sender.name,
      author_icon: data.sender.avatar_url,
      footer: data.repo.name,
      footer_icon: data.owner.avatar_url,
      color: "#a7c7f9",
      callback_id: "issue_actions",
      actions: [
        %{name: "mute_issue",
         text: "Mute #{humanize(data.issue.type)}",
         type: "button",
         value: Poison.encode!(%{repo_github_id: data.repo.id,
                                 github_id:      data.issue.id,
                                 title:          data.issue.title,
                                 type:           data.issue.type})}
      ]
    }]
  end

  defp humanize(string) do
    string
    |> to_string()
    |> String.replace("_", " ")
    |> String.capitalize()
  end
end
