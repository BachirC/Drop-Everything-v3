defmodule Dev3.SlackMessenger.HTTPClient.WatchReposResponse do
  @moduledoc """
    Defines the Slack response message attachments for command /wachrepos.
  """

  @behaviour Dev3.SlackMessenger.HTTPClient

  @statuses ~w(not_found no_rights success)a

  def build_message(data) do
    %{text: "", attachments: build_attachments(data)}
  end

  defp build_attachments(data) do
    # To reorder the repos by status following @statuses order for better display
    @statuses -- (@statuses -- Map.keys(data))
    |> Enum.reduce([], fn(key, acc) ->
      if Enum.empty?(data[key]), do: acc, else: [attachments(key, data[key]) | acc]
      end)
  end

  defp attachments(:not_found, repos) do
    %{
      title: """
       :no_entry_sign: GitBruh cannot watch these repos at the moment. Make sure you have granted GitBruh access to them\
       (<https://help.github.com/articles/requesting-organization-approval-for-your-authorized-applications|See GitHub doc>).\
       Once access is granted, you will need to re-issue /watchrepos.
      """,
      text: "· " <> Enum.join(repos, "\n· "),
      mrkdwn_in: ["title"],
      color: "#ef0e02"
    }
  end
  # TODO: Add link to "How to add DEv3 webhook on GitHub"
  defp attachments(:no_rights, repos) do
    %{
      title: """
      :hourglass_flowing_sand: You started watching these repos but you don't have enough permissions to add a webhook to them. \
      The next step is to ask an owner to add the webhook by issuing /watchrepos or <https://bachirc.github.io/Drop-Everything-v3-web/#Add-webhook-manually|manually>. \
      Once the webhook is added, you are good to go ! No need to re-issue /watchrepos.
      """,
      text: "· " <> Enum.join(repos, "\n· "),
      color: "#ed8a00"
    }
  end
  defp attachments(:success, repos) do
    %{
      title: ":thumbsup: You are now watching these repos ! You will start receiving messages related to them.",
      text: "· " <> Enum.join(repos, "\n· "),
      color: "#09c600"
    }
  end
end
