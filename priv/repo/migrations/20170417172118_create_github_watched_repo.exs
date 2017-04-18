defmodule Dev3.Repo.Migrations.CreateDev3.GitHub.WatchedRepo do
  use Ecto.Migration

  def change do
    create table(:watched_repos) do
      add :github_id, :integer, null: false
      add :full_name, :string, null: false
      add :user_id, references(:users, on_delete: :delete_all, type: :binary_id), null: false

      timestamps()
    end

    create index(:watched_repos, [:user_id])
  end
end
