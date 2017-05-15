defmodule Dev3.GitHub.SilencedIssue do
  use Ecto.Schema
  import Ecto.Query
  alias Dev3.Repo

  schema "silenced_issues" do
    field :title, :string
    field :github_id, :integer

    belongs_to :user, Dev3.User, type: :binary_id
    belongs_to :repo, Dev3.GitHub.WatchedRepo

    timestamps()
  end

  def silenced?(user, github_id) do
    query = from issue in __MODULE__,
            where: issue.github_id == ^github_id and issue.user_id == type(^user.id, Ecto.UUID),
            select: issue.id

    !is_nil(Repo.one(query))
  end
end
