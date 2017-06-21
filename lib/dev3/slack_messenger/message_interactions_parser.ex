defmodule Dev3.SlackMessenger.MessageInteractionsParser do
  @moduledoc false

  alias Dev3.GitHub.WatchedRepo
  alias Dev3.GitHub.MutedIssue

  def parse(:snooze = action, _user, %{"actions" => actions, "original_message" => original_message}) do
    %{"value" => selected_value} = actions
                                   |> List.first()
                                   |> Map.get("selected_options")
                                   |> List.first()
                                   |> Map.get("value")
                                   |> Poison.decode!()

    snooze_duration = calculate_snooze_duration(selected_value)
    attachments = update_action(action, original_message, %{"ts" => original_message["ts"]})

    %{attachments: [attachments], snooze_duration: snooze_duration}
  end
  def parse(:mute_issue = action, user, %{"original_message" => original_message} = params) do
    issue_data = extract_action_value(action, params)
    repo_id = WatchedRepo.retrieve(user, issue_data["repo_github_id"])

    issue_data
    |> Map.put("user_id", user.id)
    |> Map.put("repo_id", repo_id)
    |> MutedIssue.mute()

    attachments = update_action(action, original_message, %{"name"  => "unmute_issue",
                                                            "text"  => "Unmute",
                                                            "value" => Poison.encode!(issue_data)})

    %{attachments: [attachments], params: params}
  end
  def parse(:unmute_issue = action, user, %{"original_message" => original_message} = params) do
    issue_data = extract_action_value(action, params)

    issue_data
    |> Map.put("user_id", user.id)
    |> MutedIssue.unmute()

    attachments = update_action(action, original_message, %{"name"  => "mute_issue",
                                                            "text"  => "Mute #{humanize(issue_data["type"])}",
                                                            "value" => Poison.encode!(issue_data)})

    %{attachments: [attachments], params: params}
  end
  def parse(action, _user, _params) do
    raise "Can't parse action #{inspect action} in #{__MODULE__}"
  end

  defp calculate_snooze_duration(selected_value) do
    case selected_value do
      1 -> 1 * 3600
      2 -> 24 * 3600
    end
  end

  defp extract_action_value(action_name, params) do
    params["actions"]
    |> Enum.find(fn action -> action["name"] == to_string(action_name) end)
    |> Map.get("value")
    |> Poison.decode!()
  end

  defp update_action(:snooze = action_name, %{"attachments" => attachments}, params) do
    attachments
    |> List.first()
    |> Map.update!("actions", &Enum.reject(&1, fn action -> action["name"] != to_string(action_name) end))
    |> Map.merge(params)
  end
  defp update_action(action_name, %{"attachments" => attachments}, params) do
    actions = attachments
              |> List.first()
              |> Map.get("actions")

    new_action = actions
                 |> Enum.find(fn action -> action["name"] == to_string(action_name) end)
                 |> Map.merge(params)

    updated_actions = actions
                      |> Enum.reject(fn action -> action["name"] == to_string(action_name) end)
    attachments
    |> List.first()
    |> Map.put("actions", [new_action | updated_actions])
  end

  defp humanize(string) do
    string
    |> to_string()
    |> String.replace("_", " ")
    |> String.capitalize()
  end
end
