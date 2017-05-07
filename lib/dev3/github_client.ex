defmodule Dev3.GitHubClient do
  @moduledoc """
    Defines the contract for GitHubClient behaviour.
  """

  @doc "Create GitHub webhooks for given repos"
  @callback create_webhooks(user :: struct, repos :: list(binary)) :: {atom, list(struct)}
end
