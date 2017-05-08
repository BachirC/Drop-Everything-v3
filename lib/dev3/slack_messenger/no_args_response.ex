defmodule Dev3.SlackMessenger.HTTPClient.NoArgsResponse do
  @moduledoc """
    Defines the Slack response message attachments for command issued without args.
  """

  @behaviour Dev3.SlackMessenger.HTTPClient

  def build_message(data) do
    %{text: "", attachments: build_attachments(data)}
  end

  defp build_attachments(data) do
    [%{
      "title": "Error on command #{data}",
      "text": "You must provide at least one argument. Separate subsequent arguments with a whitespace.",
      "color": "#ef0e02"
    }]
  end
end
