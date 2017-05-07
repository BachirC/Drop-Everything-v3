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
  @callback build_attachments(data :: list(binary)) :: binary

  alias Dev3.SlackBot

  @bot_username "DEv3-Bot"

  def notify(message_type, user, data) do
    with %{slack_access_token: bot_token} <- SlackBot.retrieve_bot(user) do
      attachments = apply(Module.concat([__MODULE__, Macro.camelize(message_type)]), :build_attachments, [data])
      with %{"channel" => %{"id" => channel_id}} <- Slack.Web.Im.open(user.slack_user_id, %{token: bot_token}),
        %{"ok" => true} <- Slack.Web.Chat.post_message(channel_id, "", %{token: bot_token,
                                                                         attachments: attachments,
                                                                         username: @bot_username}) do
          :ok
      end
    end
  end
end
