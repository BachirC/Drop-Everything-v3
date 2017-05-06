defmodule Dev3.GitHubClient do
  @callback create_webhooks(user :: struct, repos :: list(binary)) :: {atom, list(struct)}
end
