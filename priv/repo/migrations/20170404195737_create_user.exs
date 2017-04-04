defmodule Dev3.Repo.Migrations.CreateDev3.User do
  use Ecto.Migration

  def change do
    create table(:users, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :slack_team_id, :string, null: false
      add :slack_user_id, :string, null: false
      add :slack_access_token, :string, null: false
      add :slack_bot_access_token, :string, null: false
      add :is_slack_bot, :boolean, default: false, null: false
      add :github_user_id, :string
      add :github_access_token, :string

      timestamps()
    end

  end
end
