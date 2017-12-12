defmodule Dev3.GitHub.MutedIssue do
  @moduledoc"""
    Schema representing an issue that has been muted by a user via Slack
  """

  use Ecto.Schema
  import Ecto.Query
  import Ecto.Changeset
  alias Dev3.Repo

  schema "muted_issues" do
    field :title, :string
    field :github_id, :integer

    belongs_to :user, Dev3.User, type: :binary_id
    belongs_to :repo, Dev3.GitHub.WatchedRepo

    timestamps()
  end

  def unmute(params) do
    issue = Repo.get_by(__MODULE__, %{user_id: params["user_id"], github_id: params["github_id"]})

    if issue, do: Repo.delete(issue)
  end

  def mute(params) do
    chgset = create_changeset(%__MODULE__{}, params)
    if chgset.valid?, do: Repo.insert(chgset, on_conflict: :nothing, conflict_target: [:github_id, :user_id])
  end

  def muted?(user, github_id) do
    query = from issue in __MODULE__,
            where: issue.github_id == ^github_id and issue.user_id == type(^user.id, Ecto.UUID),
            select: issue.id

    !is_nil(Repo.one(query))
  end

  @create_fields ~w(title github_id repo_id user_id)a
  defp create_changeset(issue, params) do
    issue
    |> cast(params, @create_fields)
    |> validate_required(@create_fields)
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:repo_id)
  end
end
