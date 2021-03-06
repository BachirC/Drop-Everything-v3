defmodule Dev3.SlackMessenger.HTTPClient.ReviewSubmitted do
  @moduledoc false

  @behaviour Dev3.SlackMessenger.HTTPClient

  import Dev3.SlackMessenger.MessageBuilder

  @status_emojis %{approved:          ":thumbsup:",
                   commented:         ":thinking_face:",
                   changes_requested: ":x:"}

  def build_message(data) do
    %{text: "", attachments: build_attachments(data)}
  end

  defp build_text(:approved, data) do
    " PR approved · Pull request ##{data.issue.number} · #{data.issue.title}"
  end
  defp build_text(:changes_requested, data) do
    " Changes requested · Pull request ##{data.issue.number} · #{data.issue.title}"
  end
  defp build_text(:commented, data) do
    " New review comments · Pull request ##{data.issue.number} · #{data.issue.title}"
  end
  defp build_text(review_status, _data) do
    raise "Review status #{inspect review_status} is undefined"
  end

  defp build_attachments(data) do
    attachment = data
                 |> base_attachment()
                 |> add_action(:snooze, data)
                 |> add_action(:mute_issue, data)

    [attachment]
  end

  defp base_attachment(data) do
    %{title: @status_emojis[data.review.state] <> build_text(data.review.state, data),
     title_link: data.review.url,
     author_name: data.sender.name,
     author_icon: data.sender.avatar_url,
     footer: data.repo.name,
     footer_icon: data.repo.owner.avatar_url,
     color: "#366bc1",
     callback_id: "issue_actions",
     actions: []}
  end
end
