defmodule Dev3.GitHub.SilencedIssue do
  use Ecto.Schema

  schema "silenced_issue" do
    field :github_id, :integer

    belongs_to :user, Dev3.User, type: :binary_id
    belongs_to :repo, Dev3.GitHub.WatchedRepo

    timestamps()
  end
end
