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

  @behaviour Dev3.SlackMessenger
  @callback build_message(data :: list(binary)) :: binary

  alias Dev3.SlackBot

  @bot_username "DEv3-Bot"

  @message_type_modules %{watch_repos_response:     WatchReposResponse,
                          unwatch_repos_response:   UnwatchReposResponse,
                          no_args_response:         NoArgsResponse,
                          review_requested:         ReviewRequested,
                          review_submitted:         ReviewSubmitted,
                          review_comment_submitted: ReviewCommentSubmitted}

  @message_types Map.keys(@message_type_modules)

  def notify(message_type, user, data) when message_type in @message_types do
    with %{slack_access_token: bot_token} <- SlackBot.retrieve_bot(user),
      message <- apply(Module.concat([__MODULE__, @message_type_modules[message_type]]),
                      :build_message,
                      [data]),
      %{"channel" => %{"id" => channel_id}} <- Slack.Web.Im.open(user.slack_user_id, %{token: bot_token}),
      %{"ok" => true} <- Slack.Web.Chat.post_message(channel_id,
                                                     message.text,
                                                     %{token: bot_token,
                                                       attachments: Poison.encode!(message.attachments),
                                                       username: @bot_username}) do
        :ok
    end
  end

  def notify(message_type, _user, _data) do
    {:unknown_message_type, message_type}
  end
end
