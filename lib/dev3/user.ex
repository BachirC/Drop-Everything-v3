defmodule Dev3.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias Dev3.Repo

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "users" do
    field :github_access_token, :string
    field :github_user_id, :string
    field :slack_access_token, :string
    field :slack_team_id, :string
    field :slack_user_id, :string

    has_many :watched_repos, Dev3.GitHub.WatchedRepo
    timestamps()
  end

  @doc """
    Updates user with given provider info.
  """
  def update(id, provider, params) do
    case Repo.get(__MODULE__, id) do
      nil -> {:error, id, provider}
      user -> update_changeset(provider, user, params) |> Repo.update
    end
  end

  @doc """
    Creates a new user with Slack info if no matching {:slack_team_id, :slack_user_id} exists,
    or updates the access_token otherwise.
  """
  def insert_or_update(params) do
     case retrieve_with_slack(params) do
       nil ->  create_changeset(%__MODULE__{}, params)
       user -> update_changeset("slack", user, params)
     end
     |> Repo.insert_or_update
  end

  def retrieve_with_slack(params) do
    # Comparing to nil values in query is forbidden
    Repo.get_by(__MODULE__, Enum.reject(params, fn {_k, v} -> is_nil(v) end))
  end

#============== Changesets ===============#

  @create_fields ~w(slack_user_id slack_team_id slack_access_token)a
  defp create_changeset(user, params) do
    user
    |> cast(params, @create_fields)
    |> validate_required(@create_fields)
  end

  defp update_changeset("slack", user, params) do
    update_fields = ~w(slack_access_token)a
    user
    |> cast(params, update_fields)
    |> validate_required(update_fields)
  end
  defp update_changeset("github", user, params) do
    update_fields = ~w(github_access_token github_user_id)a
    user
    |> cast(params, update_fields)
    |> validate_required(update_fields)
  end
end
