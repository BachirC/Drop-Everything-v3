defmodule Dev3.SlackMessenger do
  @moduledoc """
    Defines the contract for SlackMessenger behaviour.
  """

  @doc """
    Sends a message to a Slack user on behalf of the DEv3 Slack team bot.
  """
  @callback notify(message_type :: binary, user :: struct, data :: list(binary)) :: {atom | struct}
  @callback update_message(user :: struct, params :: list(binary)) :: {atom | struct}
end
