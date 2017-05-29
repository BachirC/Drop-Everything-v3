defmodule Dev3.SlackMessenger.MessageBuilder do
  def add_action(attachment, action, data) do
    Map.update(attachment,
               :actions,
               [action_params(action, data)],
               fn actions -> [action_params(action, data) | actions] end)
  end

  def humanize(string) do
    string
    |> to_string()
    |> String.replace("_", " ")
    |> String.capitalize()
  end

  defp action_params(:mute_issue, data) do
    %{name: "mute_issue",
     text: "Mute #{humanize(data.issue.type)}",
     type: "button",
     value: button_value(data)}
  end

  defp action_params(:unmute_issue, data) do
    %{name: "unmute_issue",
     text: "Unmute",
     type: "button",
     value: button_value(data)}
  end

  defp action_params(:snooze, data) do
    %{name: "snooze",
      text: "Snooze...",
      type: "select",
      options: [%{text: "For 1 hour", value: menu_option_value(data, 1)},
                %{text: "Until tomorrow", value: menu_option_value(data, 2)},
                %{text: "Now", value: menu_option_value(data, 3)}]}
  end

  defp button_value(data) do
    data
    |> issue_info()
    |> Poison.encode!()
  end

  defp menu_option_value(data, value) do
    data
    |> issue_info()
    |> Map.put(:message_type, "tagged_in_issue_comment")
    |> Map.put(:value, value)
    |> Poison.encode!()
  end

  defp issue_info(data) do
    %{repo_github_id: data.repo.id,
      github_id:      data.issue.id,
      title:          data.issue.title,
      type:           data.issue.type}
  end
end
