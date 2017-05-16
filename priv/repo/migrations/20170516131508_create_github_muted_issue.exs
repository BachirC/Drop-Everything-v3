defmodule Dev3.Repo.Migrations.CreateDev3.GitHub.MutedIssue do
  use Ecto.Migration

  def change do
    create table(:muted_issues) do
      add :title, :string, null: false
      add :github_id, :integer, null: false

      add :user_id, references(:users, on_delete: :delete_all, type: :binary_id), null: false
      add :repo_id, references(:watched_repos, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:muted_issues, [:user_id])
    create index(:muted_issues, [:repo_id])
    create unique_index(:muted_issues, [:user_id, :github_id])
  end
end
