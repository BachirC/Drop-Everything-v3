defmodule Dev3.Repo.Migrations.CreateDev3.GitHub.SilencedIssue do
  use Ecto.Migration

  def change do
    create table(:silenced_issues) do
      add :title, :string, null: false
      add :github_id, :integer, null: false

      add :user_id, references(:users, on_delete: :delete_all, type: :binary_id), null: false
      add :repo_id, references(:watched_repos, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:silenced_issues, [:user_id])
    create index(:silenced_issues, [:repo_id])
  end
end
