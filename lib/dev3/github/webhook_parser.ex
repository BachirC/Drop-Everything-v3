defmodule Dev3.GitHub.WebhookParser do
  @moduledoc """
    Defines the contract for WebhookParser behaviour.
  """

  @callback parse(message_type :: atom, params :: map) :: {status :: atom,
                                                           users :: list(map),
                                                           message_config :: map}
end
