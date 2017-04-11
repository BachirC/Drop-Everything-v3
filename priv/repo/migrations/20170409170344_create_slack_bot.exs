defmodule Dev3.Repo.Migrations.CreateDev3.SlackBot do
  use Ecto.Migration

  def change do
    create table(:slack_bots) do
      add :slack_team_id, :string, null: false
      add :slack_user_id, :string, null: false
      add :slack_access_token, :string, null: false

      timestamps()
    end

  end
end
