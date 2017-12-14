defmodule Dev3.GitHub.WebhookParser.Mock do
  @moduledoc """
    Mock for WebhookParser.Real
  """

  @behaviour Dev3.GitHub.WebhookParser

  @message_types Map.values(Application.get_env(:dev3, GitHub)[:message_types_by_action])
  def parse(message_type, _params) when message_type in @message_types do
    {:ok, [], %{}}
  end
  def parse(message_type, _params) do
    {:unhandled_message_type, message_type}
  end
end
