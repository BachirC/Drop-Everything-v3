defmodule Dev3.SlackMessenger do
  @moduledoc """
    Defines the contract for SlackMessenger behaviour.
  """

  @doc """
    Sends a message to a Slack user on behalf of the DEv3 Slack team bot.
  """
  @callback notify(message_type :: binary, user :: struct, data :: list(binary)) :: atom
  @callback update(user :: struct, params :: list(binary)) :: atom
  @callback deliver(user :: struct, params :: list(binary)) :: atom
end
