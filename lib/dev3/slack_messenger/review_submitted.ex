defmodule Dev3.SlackMessenger.HTTPClient.ReviewSubmitted do
  @behaviour Dev3.SlackMessenger.HTTPClient

  def build_message(data) do
   %{text: "A Review has been submitted to your Pull Request", attachments: build_attachments(data)}
  end

  defp build_attachments(data) do
    [%{
      "title" => "PR link",
      "title_link" => "https://google.fr",
      "text" => "",
      "author_name" => "Me",
      "author_icon" => "",
      "footer" => "footer",
      "footer_icon" => "",
      "color" => "#ef0e02",
      "ts" => 1494261981
    }]
  end
end
