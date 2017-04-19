defmodule Dev3.GitHub.WatchedRepo do
  use Ecto.Schema
  import Ecto.Query
  import Ecto.Changeset
  alias Dev3.Repo

  schema "watched_repos" do
    field :full_name, :string
    field :github_id, :integer
    belongs_to :user, Dev3.User, type: :binary_id
  end

  # TODO: Add bulk creation, for now Ecto.insert_all/3 is limited (doesn't
  # handle changesets and automatic generation of timestamps)
  # https://github.com/elixir-ecto/ecto/blob/f23688e6ce94c97519bac14eaf0c36e99e0f205e/lib/ecto/repo.ex#L414-L440
  def create(user, params) do
    if (!retrieve(user, params)), do: Repo.insert(create_changeset(%__MODULE__{}, Map.put_new(params, :user_id, user.id)))
  end

  def insert_watched(user, repos) do
    Repo.insert_all(__MODULE__, repos,
                    on_conflict: :nothing,
                    conflict_target: [:user_id, :full_name])
  end

  def delete_unwatched(user, full_names) do
    query = from repo in "watched_repos",
            where: repo.user_id == type(^user.id, Ecto.UUID) and repo.full_name in ^full_names

    Repo.delete_all(query)
  end

  defp retrieve(user, params) do
    Repo.get_by(__MODULE__, [user_id: user.id, full_name: params.full_name, github_id: params.github_id])
  end

  #====== Changesets =======#

  @create_fields ~w(user_id github_id full_name)a
  @required_fields ~w(github_id full_name)a
  defp create_changeset(repo, params) do
    repo
    |> cast(params, @create_fields)
    |> validate_required(@required_fields)
    |> assoc_constraint(:user)
  end
end
