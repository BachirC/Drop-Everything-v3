defmodule Dev3.SlackMessenger do
  @callback notify(message_type :: binary, user :: struct, data :: list(binary)) :: struct
end
