defmodule Dev3.SlackMessenger.MessageInteractionsParserTest do
  use ExUnit.Case
  alias Dev3.Repo
  alias Dev3.User
  alias Dev3.GitHub.WatchedRepo
  alias Dev3.GitHub.MutedIssue
  alias Dev3.SlackMessenger.MessageInteractionsParser

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
  end

  test "mute_issue" do
    user = Repo.insert!(%User{github_id: 1, slack_team_id: "ST1", slack_user_id: "SU1", slack_access_token: "SAT1"})
    Repo.insert!(%WatchedRepo{github_id: 1, full_name: "Repo name", user_id: user.id})
    payload = Path.expand("../fixtures/slack_api/action_invocations/mute_issue.json", __DIR__)
              |> File.read!()
              |> Poison.decode!()
    expected = %{attachments: [%{"actions" => [%{"id" => "1", "name" => "unmute_issue",
                                                 "style" => "", "text" => "Unmute", "type" => "button",
                                                 "value" => ~s({\"type\":\"pull_request\",\"title\":\"More dummy text\",\"repo_github_id\":1,\"github_id\":1})}],
                                 "author_icon" => "https://avatars3.githubusercontent.com/u/7337242?v=3",
                                 "author_name" => "BachirC", "callback_id" => "issue_actions",
                                 "color" => "a7c7f9",
                                 "fallback" => "You have been mentioned · Pull request #58 · More dummy text",
                                 "footer" => "DropEverythingOrg/DummyRepo",
                                 "footer_icon" => "https://avatars0.githubusercontent.com/u/27590286?v=3",
                                 "id" => 1,
                                 "title" => "You have been mentioned · Pull request #58 · More dummy text",
                                 "title_link" => "https:\/\/github.com\/fancy\/url"}],
                 params: %{"action_ts" => "1495019361.226665",
                           "actions" => [%{"name" => "mute_issue",
                                           "type" => "button",
                                           "value" => ~s({\"type\":\"pull_request\", \"title\":\"More dummy text\", \"repo_github_id\":1, \"github_id\":1})}],
                           "attachment_id" => "1", "callback_id" => "issue_actions",
                           "channel" => %{"id" => "channel_id", "name" => "directmessage"},
                           "is_app_unfurl" => false,
                           "message_ts" => "1495019112.945270",
                           "original_message" => %{"attachments" => [
                                                   %{"actions" => [
                                                     %{"id" => "1",
                                                       "name" => "mute_issue",
                                                       "style" => "",
                                                       "text" => "Mute Pull request",
                                                       "type" => "button",
                                                       "value" => ~s({\"type\":\"pull_request\", \"title\":\"More dummy text\", \"repo_github_id\":1, \"github_id\":1})}],
                                                     "author_icon" => "https://avatars3.githubusercontent.com/u/7337242?v=3",
                                                     "author_name" => "BachirC",
                                                     "callback_id" => "issue_actions",
                                                     "color" => "a7c7f9",
                                                     "fallback" => "You have been mentioned · Pull request #58 · More dummy text",
                                                     "footer" => "DropEverythingOrg/DummyRepo",
                                                     "footer_icon" => "https://avatars0.githubusercontent.com/u/27590286?v=3",
                                                     "id" => 1,
                                                     "title" => "You have been mentioned · Pull request #58 · More dummy text",
                                                     "title_link" => "https:\/\/github.com\/fancy\/url"}],
                           "bot_id" => "SBU1",
                           "subtype" => "bot_message",
                           "text" => "",
                           "ts" => "1495019112.945270",
                           "type" => "message",
                           "username" => "DEv3-Bot"},
                           "response_url" => "https:\/\/hooks.slack.com\/some\/cool\/url",
                           "team" => %{"domain" => "team_domain", "id" => "ST1"},
                           "token" => "secret_token",
                           "user" => %{"id" => "SU1", "name" => "bachir"}}}

    assert MessageInteractionsParser.parse(:mute_issue, user, payload) == expected
    assert Repo.aggregate(MutedIssue, :count, :id) == 1
  end

  test "unmute_issue" do
    user = Repo.insert!(%User{github_id: 1, slack_team_id: "ST1", slack_user_id: "SU1", slack_access_token: "SAT1"})
    repo = Repo.insert!(%WatchedRepo{github_id: 1, full_name: "Repo name", user_id: user.id})
    Repo.insert!(%MutedIssue{github_id: 1, repo_id: repo.id, user_id: user.id, title: "More dummy text"})
    payload = Path.expand("../fixtures/slack_api/action_invocations/unmute_issue.json", __DIR__)
              |> File.read!()
              |> Poison.decode!()
    expected = %{attachments: [%{"actions" => [%{"id" => "1", "name" => "mute_issue",
                                                 "style" => "", "text" => "Mute Pull request", "type" => "button",
                                                 "value" => ~s({\"type\":\"pull_request\",\"title\":\"More dummy text\",\"repo_github_id\":1,\"github_id\":1})}],
                                 "author_icon" => "https://avatars3.githubusercontent.com/u/7337242?v=3",
                                 "author_name" => "BachirC", "callback_id" => "issue_actions",
                                 "color" => "a7c7f9",
                                 "fallback" => "You have been mentioned · Pull request #58 · More dummy text",
                                 "footer" => "DropEverythingOrg/DummyRepo",
                                 "footer_icon" => "https://avatars0.githubusercontent.com/u/27590286?v=3",
                                 "id" => 1,
                                 "title" => "You have been mentioned · Pull request #58 · More dummy text",
                                 "title_link" => "https:\/\/github.com\/fancy\/url"}],
                 params: %{"action_ts" => "1495043495.926595",
                           "actions" => [%{"name" => "unmute_issue",
                                           "type" => "button",
                                           "value" => ~s({\"type\":\"pull_request\", \"title\":\"More dummy text\", \"repo_github_id\":1, \"github_id\":1})}],
                           "attachment_id" => "1", "callback_id" => "issue_actions",
                           "channel" => %{"id" => "channel_id", "name" => "directmessage"},
                           "is_app_unfurl" => false,
                           "message_ts" => "1495019361.226665",
                           "original_message" => %{"attachments" => [
                                                   %{"actions" => [
                                                     %{"id" => "1",
                                                       "name" => "unmute_issue",
                                                       "style" => "",
                                                       "text" => "Unmute",
                                                       "type" => "button",
                                                       "value" => ~s({\"type\":\"pull_request\", \"title\":\"More dummy text\", \"repo_github_id\":1, \"github_id\":1})}],
                                                     "author_icon" => "https://avatars3.githubusercontent.com/u/7337242?v=3",
                                                     "author_name" => "BachirC",
                                                     "callback_id" => "issue_actions",
                                                     "color" => "a7c7f9",
                                                     "fallback" => "You have been mentioned · Pull request #58 · More dummy text",
                                                     "footer" => "DropEverythingOrg/DummyRepo",
                                                     "footer_icon" => "https://avatars0.githubusercontent.com/u/27590286?v=3",
                                                     "id" => 1,
                                                     "title" => "You have been mentioned · Pull request #58 · More dummy text",
                                                     "title_link" => "https:\/\/github.com\/fancy\/url"}],
                           "bot_id" => "SBU1",
                           "subtype" => "bot_message",
                           "text" => "",
                           "ts" => "1495019361.226665",
                           "type" => "message",
                           "username" => "DEv3-Bot"},
                           "response_url" => "https:\/\/hooks.slack.com\/some\/cool\/url",
                           "team" => %{"domain" => "team_domain", "id" => "ST1"},
                           "token" => "secret_token",
                           "user" => %{"id" => "SU1", "name" => "bachir"}}}

    assert MessageInteractionsParser.parse(:unmute_issue, user, payload) == expected
    assert Repo.aggregate(MutedIssue, :count, :id) == 0
  end
end
