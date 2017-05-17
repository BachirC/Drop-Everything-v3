defmodule Dev3.GitHub.WebhookParser.RealTest do
  use ExUnit.Case
  alias Dev3.GitHub.WebhookParser.Real
  alias Dev3.Repo
  alias Dev3.User
  alias Dev3.GitHub.WatchedRepo
  alias Dev3.GitHub.MutedIssue

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
  end

  test "returns an error when message_type not handled" do
    assert Real.parse(:action_non_handled, %{}) == {:unhandled_message_type, :action_non_handled}
  end

  test "review_requested" do
    user = Repo.insert!(%User{github_id: 1, slack_team_id: "ST1", slack_user_id: "SU1", slack_access_token: "SAT1"})
    insert_watched_repo(user)
    payload = Path.expand("../../fixtures/github_api/webhooks/pull_request/review_requested.json", __DIR__)
              |> File.read!()
              |> Poison.decode!()
    expected = {:ok,
      [Map.take(user, [:id, :slack_team_id, :slack_user_id])],
      %{branches: %{base: "master", head: "changes"},
        issue: %{body: "This is a pretty simple change that we need to pull into master.",
                id: 34778301,
                number: 1,
                title: "Update the README with new information",
                type: :pull_request,
                url: "https://github.com/baxterthehacker/public-repo/pull/1"},
        owner: %{avatar_url: "https://avatars.githubusercontent.com/u/6752317?v=3"},
        repo: %{id: 35129377,
                name: "baxterthehacker/public-repo",
                url: "https://github.com/baxterthehacker/public-repo"},
        sender: %{avatar_url: "https://avatars.githubusercontent.com/u/6752317?v=3",
                  name: "baxterthehacker"}}}

    res = Real.parse(:review_requested, payload)

    assert res == expected
  end

  test "review_submitted" do
    user = Repo.insert!(%User{github_id: 2546, slack_team_id: "ST1", slack_user_id: "SU1", slack_access_token: "SAT1"})
    insert_watched_repo(user)
    payload = Path.expand("../../fixtures/github_api/webhooks/pull_request_review/submitted.json", __DIR__)
              |> File.read!()
              |> Poison.decode!()
    expected = {:ok,
                [Map.take(user, [:id, :slack_team_id, :slack_user_id])],
                %{branches: %{base: "master", head: "patch-2"},
                  issue: %{body: "Just a few more details",
                          id: 87811438,
                          number: 8,
                          title: "Add a README description",
                          type: :pull_request,
                          url: "https://github.com/baxterthehacker/public-repo/pull/8"},
                  owner: %{avatar_url: "https://avatars.githubusercontent.com/u/6752317?v=3"},
                  repo: %{id: 35129377,
                          name: "baxterthehacker/public-repo",
                          url: "https://github.com/baxterthehacker/public-repo"},
                  sender: %{avatar_url: "https://avatars.githubusercontent.com/u/6752317?v=3",
                            name: "baxterthehacker"},
                  review: %{body: "Looks great!",
                            state: :approved,
                            url: "https://github.com/baxterthehacker/public-repo/pull/8#pullrequestreview-2626884"}}}

    res = Real.parse(:review_submitted, payload)

    assert res == expected
  end

  test "tagged_in_issue" do
    user = Repo.insert!(%User{github_id: 1, github_user_id: "BachirC", slack_team_id: "ST1", slack_user_id: "SU1", slack_access_token: "SAT1"})
    insert_watched_repo(user)
    payload = Path.expand("../../fixtures/github_api/webhooks/issues/opened.json", __DIR__)
              |> File.read!()
              |> Poison.decode!()
    expected = {:ok,
                [Map.take(user, [:id, :slack_team_id, :slack_user_id])],
                %{issue: %{body: "You have been tagged @BachirC",
                          id: 73464126,
                          number: 2,
                          title: "Spelling error in the README file",
                          type: :issue,
                          url: "https://github.com/baxterthehacker/public-repo/issues/2"},
                  owner: %{avatar_url: "https://avatars.githubusercontent.com/u/6752317?v=3"},
                  repo: %{id: 35129377,
                          name: "baxterthehacker/public-repo",
                          url: "https://github.com/baxterthehacker/public-repo"},
                  sender: %{avatar_url: "https://avatars.githubusercontent.com/u/6752317?v=3",
                            name: "baxterthehacker"}}}

    res = Real.parse(:tagged_in_issue, payload)

    assert res == expected
  end

  test "tagged_in_issue_comment" do
    user = Repo.insert!(%User{github_id: 1, github_user_id: "BachirC", slack_team_id: "ST1", slack_user_id: "SU1", slack_access_token: "SAT1"})
    insert_watched_repo(user)
    payload = Path.expand("../../fixtures/github_api/webhooks/issue_comment/created.json", __DIR__)
              |> File.read!()
              |> Poison.decode!()
    expected = {:ok,
                [Map.take(user, [:id, :slack_team_id, :slack_user_id])],
                %{issue: %{body: "It looks like you accidently spelled 'commit' with two 't's.",
                          id: 73464126,
                          number: 2,
                          title: "Spelling error in the README file",
                          type: :issue,
                          url: "https://github.com/baxterthehacker/public-repo/issues/2"},
                  owner: %{avatar_url: "https://avatars.githubusercontent.com/u/6752317?v=3"},
                  repo: %{id: 35129377,
                          name: "baxterthehacker/public-repo",
                          url: "https://github.com/baxterthehacker/public-repo"},
                  sender: %{avatar_url: "https://avatars.githubusercontent.com/u/6752317?v=3",
                            name: "baxterthehacker"},
                  comment: %{url: "https://github.com/baxterthehacker/public-repo/issues/2#issuecomment-99262140",
                             body: "You have been tagged @BachirC"}}}

    res = Real.parse(:tagged_in_issue_comment, payload)

    assert res == expected
  end

  test "Doesn't target the user if he is not watching the repo" do
    Repo.insert!(%User{github_id: 1, github_user_id: "BachirC", slack_team_id: "ST1", slack_user_id: "SU1", slack_access_token: "SAT1"})
    payload = Path.expand("../../fixtures/github_api/webhooks/issue_comment/created.json", __DIR__)
              |> File.read!()
              |> Poison.decode!()
    expected = {:ok,
                [],
                %{issue: %{body: "It looks like you accidently spelled 'commit' with two 't's.",
                          id: 73464126,
                          number: 2,
                          title: "Spelling error in the README file",
                          type: :issue,
                          url: "https://github.com/baxterthehacker/public-repo/issues/2"},
                  owner: %{avatar_url: "https://avatars.githubusercontent.com/u/6752317?v=3"},
                  repo: %{id: 35129377,
                          name: "baxterthehacker/public-repo",
                          url: "https://github.com/baxterthehacker/public-repo"},
                  sender: %{avatar_url: "https://avatars.githubusercontent.com/u/6752317?v=3",
                            name: "baxterthehacker"},
                  comment: %{url: "https://github.com/baxterthehacker/public-repo/issues/2#issuecomment-99262140",
                             body: "You have been tagged @BachirC"}}}

    res = Real.parse(:tagged_in_issue_comment, payload)

    assert res == expected
  end

  test "Doesn't target the user if he muted the issue" do
    user = Repo.insert!(%User{github_id: 1, github_user_id: "BachirC", slack_team_id: "ST1", slack_user_id: "SU1", slack_access_token: "SAT1"})
    repo = insert_watched_repo(user)
    Repo.insert!(%MutedIssue{github_id: 73464126, title: "Spelling error in the README file", repo_id: repo.id, user_id: user.id})
    payload = Path.expand("../../fixtures/github_api/webhooks/issue_comment/created.json", __DIR__)
              |> File.read!()
              |> Poison.decode!()
    expected = {:ok,
                [],
                %{issue: %{body: "It looks like you accidently spelled 'commit' with two 't's.",
                          id: 73464126,
                          number: 2,
                          title: "Spelling error in the README file",
                          type: :issue,
                          url: "https://github.com/baxterthehacker/public-repo/issues/2"},
                  owner: %{avatar_url: "https://avatars.githubusercontent.com/u/6752317?v=3"},
                  repo: %{id: 35129377,
                          name: "baxterthehacker/public-repo",
                          url: "https://github.com/baxterthehacker/public-repo"},
                  sender: %{avatar_url: "https://avatars.githubusercontent.com/u/6752317?v=3",
                            name: "baxterthehacker"},
                  comment: %{url: "https://github.com/baxterthehacker/public-repo/issues/2#issuecomment-99262140",
                             body: "You have been tagged @BachirC"}}}

    res = Real.parse(:tagged_in_issue_comment, payload)

    assert res == expected
  end

  defp insert_watched_repo(user) do
    Repo.insert!(%WatchedRepo{github_id: 35129377, full_name: "baxterthehacker/public-repo", user_id: user.id})
  end
end
