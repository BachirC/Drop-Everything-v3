defmodule Dev3.SlackMessenger.HTTPClient.RateLimitExceededResponse do
  @moduledoc """
    Defines the Slack response message attachments for rate limit exceed.
  """

  @behaviour Dev3.SlackMessenger.HTTPClient

  def build_message(data) do
    %{text: "", attachments: build_attachments(data)}
  end

  defp build_attachments(data) do
    [%{
      title: "You exceeded the rate limit",
      text: "You can't make more than #{data[:max_requests]} requests during a period of #{data[:interval_seconds]} seconds. Please try again later.",
      color: "#ef0e02"
    }]
  end
end
