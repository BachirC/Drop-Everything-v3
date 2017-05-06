defmodule Dev3.SlackMessenger do
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

  @bot_username "DEv3-Bot"

  @doc """
    Sends a message to a Slack user on behalf of the DEv3 Slack team bot.
  """
  def notify(message_type, user, data) do
    %{slack_access_token: bot_token} = SlackBot.retrieve_bot(user)
    attachments = apply(Module.concat([__MODULE__, Macro.camelize(message_type)]), :build_attachments, [data])
    %{"channel" => %{"id" => channel_id}} = Slack.Web.Im.open(user.slack_user_id, %{token: bot_token})

    Slack.Web.Chat.post_message(channel_id, "", %{token: bot_token, attachments: attachments, username: @bot_username})
  end
end
