defmodule Dev3.Release.Tasks do
  def migrate do
    {:ok, _} = Application.ensure_all_started(:dev3)

    path = Application.app_dir(:dev3, "priv/repo/migrations")

    Ecto.Migrator.run(Dev3.Repo, path, :up, all: true)
  end
end
