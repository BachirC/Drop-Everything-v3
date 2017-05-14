defmodule Dev3.SlackMessenger.HTTPClient.ReviewSubmitted do
  @moduledoc """
    Defines the Slack message sent to a user when a review is submitted to one of his/her
    pull requests
  """

  @behaviour Dev3.SlackMessenger.HTTPClient
  @status_emojis %{approved:          ":white_check_mark:",
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
    attachment = %{
      title: @status_emojis[data.review.state] <> build_text(data.review.state, data),
      title_link: data.review.url,
      author_name: data.sender.name,
      author_icon: data.sender.avatar_url,
      footer: data.repo.name,
      footer_icon: data.owner.avatar_url,
      color: "#366bc1"
    }

    [attachment]
  end
end
