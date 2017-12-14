defmodule Dev3.Workers.SnoozedMessagesSender do
  @moduledoc """
    Sends snoozed messages
  """

  @slack_messenger Application.get_env(:dev3, :slack_messenger)

  alias Dev3.Repo
  alias Dev3.User

  def perform(user, attachments) do
    user = Repo.get!(User, user)
    @slack_messenger.deliver(%{text: "", attachments: Poison.decode!(attachments)}, user)
  end
end
