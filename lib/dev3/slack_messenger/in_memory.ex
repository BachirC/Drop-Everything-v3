defmodule Dev3.SlackMessenger.InMemory do
  @behaviour Dev3.SlackMessenger

  def notify(_message_type, _user, _data) do
    :ok
  end
end
