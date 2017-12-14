defmodule Dev3.GitHub.WebhookParser.Real do
  @moduledoc """
    Handles the parsing of GitHub webhooks and formatting the data for messaging
  """

  @behaviour Dev3.GitHub.WebhookParser

  alias Dev3.User
  alias Dev3.GitHub.WatchedRepo
  alias Dev3.GitHub.MutedIssue

  def parse(:notify_owner_on_issue_comment, %{"comment" => comment} = params) do
    data = params
           |> parse_issue()
           |> Map.merge(%{comment: %{url: comment["html_url"], body: comment["body"]}})

    users = fetch_recipients(data.issue.owner.id,
                             data.repo.id,
                             data.issue.id)
            |> avoid_self_messaging(data.sender)
    {:ok, users, data}
  end
  def parse(:review_requested, params) do
    data = parse_issue(params)
    users = fetch_recipients(params["requested_reviewer"]["id"],
                             data.repo.id,
                             data.issue.id)

    {:ok, users, data}
  end
  def parse(:review_submitted, %{"review" => review} = params) do
    data = params
           |> parse_issue()
           |> Map.merge(%{review: %{state: String.to_atom(review["state"]),
                                    url: review["html_url"],
                                    body: review["body"]}})

    users = fetch_recipients(data.issue.owner.id,
                             data.repo.id,
                             data.issue.id)
            |> avoid_self_messaging(data.sender)

    {:ok, users, data}
  end
  def parse(:tagged_in_issue, params) do
    data = parse_issue(params)
    users = fetch_tagged_users(data.issue.body,
                               data.repo.id,
                               data.issue.id)

    {:ok, users, data}
  end
  def parse(:tagged_in_issue_comment, %{"comment" => comment} = params) do
    data = params
           |> parse_issue()
           |> Map.merge(%{comment: %{url: comment["html_url"], body: comment["body"]}})
    users = fetch_tagged_users(data.comment.body,
                               data.repo.id,
                               data.issue.id)

    {:ok, users, data}
  end
  def parse(message_type, _params) do
    {:unhandled_message_type, message_type}
  end

  # Fetch targeted user (or users if a unique GitHub user has installed DEv3 on more than one Slack
  # team)
  defp fetch_recipients(id, repo_id, issue_id) do
    id
    |> User.list_by_github_id()
    |> filter_issue_watchers(repo_id, issue_id)
  end

  # Fetch tagged users (mentioned by "@my_username" in GitHub issue description or comment)
  defp fetch_tagged_users(body, repo_id, issue_id) do
    body
    |> extract_github_user_ids()
    |> User.list_by_github_user_ids()
    |> filter_issue_watchers(repo_id, issue_id)
  end

  defp avoid_self_messaging([], sender), do: []
  defp avoid_self_messaging(recipients, sender) do
    if sender.name == List.first(recipients).github_user_id, do: [], else: recipients
  end

  defp extract_github_user_ids(body) do
    body
    |> String.split(" ")
    |> Enum.reject(fn word -> String.at(word, 0) != "@" end)
    |> Enum.map(fn word -> String.replace(word, ~r/(?![-])\p{P}/, "") end) # GitHub usernames allow simple hyphens
  end

  defp filter_issue_watchers(users, repo_id, issue_id) do
    Enum.reject(users, fn user ->
      !WatchedRepo.watched?(user, repo_id) or MutedIssue.muted?(user, issue_id)
    end)
  end

  # All pull requests are considered issues by GitHub
  # https://developer.github.com/v3/issues/#list-issues. Therefore, when talking about
  # issues, it can refer to an Issue (non PR) or a Pull Request.

  # When comment on PR (!= review comments)
  defp parse_issue(%{"issue" => %{"pull_request" => _pull_request} = issue} = params) do
    parse_issue(issue, params, :pull_request)
  end
  # For PR related actions (review requests, review submits)
  defp parse_issue(%{"pull_request" => pull_request} = params) do
    pull_request
    |> parse_issue(params, :pull_request)
    |> Map.merge(%{branches: %{base: pull_request["base"]["ref"], head: pull_request["head"]["ref"]}})
  end
  # For non PR issues
  defp parse_issue(%{"issue" => issue} = params) do
    parse_issue(issue, params)
  end
  defp parse_issue(issue, params, issue_type \\ :issue) do
    %{"login" => sender_name, "avatar_url" => sender_avatar_url} = params["sender"]
    %{"id" => repo_id, "full_name" => repo_name, "html_url" => repo_url} = params["repository"]
    %{"id" => issue_id,
      "number" => issue_number,
      "html_url" => issue_url,
      "title" => issue_title,
      "body" => issue_body} = issue


    %{"id" => owner_id} = parse_owner(params)
    repo_owner_avatar_url = params["repository"]["owner"]["avatar_url"]

    %{issue: %{id: issue_id,
               type: issue_type,
               number: issue_number,
               url: issue_url,
               title: issue_title,
               body: issue_body,
               owner: %{id: owner_id}},
      sender: %{name: sender_name, avatar_url: sender_avatar_url},
      repo: %{id: repo_id, name: repo_name, url: repo_url, owner: %{avatar_url: repo_owner_avatar_url}}
      }
  end

  defp parse_owner(params) do
    get_in(params, ["issue", "user"]) || get_in(params, ["pull_request", "user"])
  end
end
