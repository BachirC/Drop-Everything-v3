defmodule Dev3.SlackMessenger.HTTPClient.NoArgsResponse do
  @moduledoc """
    Defines the Slack response message attachments for command issued without args.
  """

  @behaviour Dev3.SlackMessenger.HTTPClient

  def build_attachments(data) do
    [%{
      "title": "Error on command #{data}",
      "text": "You must provide at least one argument. Separate subsequent arguments with a whitespace.",
      "color": "#ef0e02"
    }] |> Poison.encode!()
  end
end
