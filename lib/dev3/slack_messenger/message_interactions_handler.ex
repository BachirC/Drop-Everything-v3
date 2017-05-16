defmodule Dev3.SlackMessenger.MessageInteractionsHandler do
  @moduledoc """
    Handles message interactions within Slack
  """

  alias Dev3.GitHub.WatchedRepo
  alias Dev3.GitHub.MutedIssue
  @slack_messenger Application.get_env(:dev3, :slack_messenger)

  def handle(:mute_issue, user, %{"original_message" => original_message} = params) do
    issue_data = extract_action_value(params)
    repo_id = WatchedRepo.retrieve(user, issue_data["repo_github_id"])

    issue_data
    |> Map.put("user_id", user.id)
    |> Map.put("repo_id", repo_id)
    |> MutedIssue.mute()

    attachments = update_action(original_message, %{"name"  => "unmute_issue",
                                                         "text"  => "Unmute",
                                                         "value" => Poison.encode!(issue_data)})

    full_params = %{attachments: [attachments], params: params}
    @slack_messenger.update_message(user, full_params)
  end

  def handle(:unmute_issue, user, %{"original_message" => original_message} = params) do
    issue_data = extract_action_value(params)

    issue_data
    |> Map.put("user_id", user.id)
    |> MutedIssue.unmute()

    attachments = update_action(original_message, %{"name"  => "mute_issue",
                                                         "text"  => "Mute #{humanize(issue_data["type"])}",
                                                         "value" => Poison.encode!(issue_data)})

    full_params = %{attachments: [attachments], params: params}
    @slack_messenger.update_message(user, full_params)
  end

  def handle(action, _params) do
    raise "Can't handle action #{action} in #{__MODULE__}"
  end

  defp extract_action_value(params) do
    params["actions"]
    |> List.first()
    |> Map.get("value")
    |> Poison.decode!()
  end

  defp update_action(original_message, action_params) do
    new_action = original_message["attachments"]
                 |> List.first()
                 |> Map.get("actions")
                 |> List.first()
                 |> Map.merge(action_params)

    original_message["attachments"]
    |> List.first()
    |> Map.put("actions", [new_action])
  end

  defp humanize(string) do
    string
    |> to_string()
    |> String.replace("_", " ")
    |> String.capitalize()
  end
end
