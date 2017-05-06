defmodule Dev3.SlackMessenger.NoArgsResponse do
  def build_attachments(data) do
    [%{
      "title": "Error on command #{data}",
      "text": "You must provide at least one argument. Separate subsequent arguments with a whitespace.",
      "color": "#ef0e02"
    }] |> Poison.encode!()
  end
end
