defmodule Dev3.Repo.Migrations.AddGithubIdToUser do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :github_id, :integer
    end
  end
end
