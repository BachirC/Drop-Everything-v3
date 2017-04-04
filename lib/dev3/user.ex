defmodule Dev3.User do
  use Ecto.Schema

  schema "users" do
    field :github_access_token, :string
    field :github_user_id, :string
    field :is_slack_bot, :boolean, default: false
    field :slack_access_token, :string
    field :slack_bot_access_token, :string
    field :slack_team_id, :string
    field :slack_user_id, :string

    timestamps()
  end
end
