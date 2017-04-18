defmodule Dev3.GitHub.WatchedRepo do
  use Ecto.Schema
  import Ecto.Changeset
  alias Dev3.Repo

  schema "watched_repos" do
    field :full_name, :string
    field :github_id, :integer
    belongs_to :user, Dev3.User, type: :binary_id

    timestamps()
  end

  # TODO: Add bulk creation, for now Ecto.insert_all/3 is limited (doesn't
  # handle changesets and automatic generation of timestamps)
  # https://github.com/elixir-ecto/ecto/blob/f23688e6ce94c97519bac14eaf0c36e99e0f205e/lib/ecto/repo.ex#L414-L440
  def create(user, params) do
    if (!retrieve(user, params)), do: Repo.insert(create_changeset(%__MODULE__{}, Map.put_new(params, :user_id, user.id)))
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
