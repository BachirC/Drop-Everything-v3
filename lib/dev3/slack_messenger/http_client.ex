defmodule Dev3.SlackMessenger.HTTPClient do
  @moduledoc """
    Real SlackMessenger handling the interaction with Slack API to send messages to users.
  """

  # HACK: `use Slack` not properly calling macro doing the following imports and definitions
  import Slack
  import Slack.Lookups
  import Slack.Sends

  def handle_connect(_slack, state), do: {:ok, state}
  def handle_event(_message, _slack, state), do: {:ok, state}
  def handle_close(_reason, _slack, state), do: :close
  def handle_info(_message, _slack, state), do: {:ok, state}

  defoverridable [handle_connect: 2, handle_event: 3, handle_close: 3, handle_info: 3]

  #===================================================================================#

  alias Dev3.SlackBot

  @behaviour Dev3.SlackMessenger
  @callback build_message(data :: list(binary)) :: binary

  @bot_username Application.get_env(:dev3, :bot_username)

  @message_type_modules %{watch_repos_response:    WatchReposResponse,
                          unwatch_repos_response:  UnwatchReposResponse,
                          no_args_response:        NoArgsResponse,
                          review_requested:        ReviewRequested,
                          review_submitted:        ReviewSubmitted,
                          tagged_in_issue:         TaggedInIssue,
                          tagged_in_issue_comment: TaggedInIssueComment}

  @message_types Map.keys(@message_type_modules)

  def notify(message_type, user, data) when message_type in @message_types do
    data
    |> Module.concat([__MODULE__, @message_type_modules[message_type]]).build_message()
    |> deliver(user)
  end
  def notify(message_type, _user, _data) do
    {:unknown_message_type, message_type}
  end

  def deliver(%{text: text, attachments: attachments}, user) do
    with %{slack_access_token: bot_token} <- SlackBot.retrieve_bot(user),
    %{"channel" => %{"id" => channel_id}} <- Slack.Web.Im.open(user.slack_user_id, %{token: bot_token}),
    %{"ok" => true} <- Slack.Web.Chat.post_message(channel_id,
                                                   text,
                                                   %{token: bot_token,
                                                    attachments: Poison.encode!(attachments),
                                                    username: @bot_username}) do
      :ok
    end
  end

  def update(%{attachments: attachments, params: params}, user) do
    with %{slack_access_token: bot_token} = SlackBot.retrieve_bot(user),
      %{"ok" => true} <- Slack.Web.Chat.update(params["channel"]["id"],
                          "",
                          params["original_message"]["ts"],
                          %{token: bot_token,
                            attachments: Poison.encode!(attachments),
                            username: @bot_username,
                            replace_original: true}) do
      :ok
    end
  end
end
