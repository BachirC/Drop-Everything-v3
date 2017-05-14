defmodule Dev3.GitHub.WatchedRepo do
  @moduledoc """
    Defines the schema for GitHub repos watched by users.
    It allows to know if a user should receive messages for a given repo.
  """

  use Ecto.Schema
  import Ecto.Query
  alias Dev3.Repo

  schema "watched_repos" do
    field :full_name, :string
    field :github_id, :integer
    belongs_to :user, Dev3.User, type: :binary_id
  end

  def list(user) do
    query = from repo in __MODULE__,
            where: repo.user_id == type(^user.id, Ecto.UUID)

    Repo.all(query)
  end

  def retrieve_watched(user, github_id) do
    query = from repo in __MODULE__,
            where: repo.user_id == type(^user.id, Ecto.UUID) and repo.github_id == ^github_id,
            select: repo.id

    Repo.one(query)
  end
  @doc """
    Start watching repos by the user.
    All incoming GitHub webhooks from these repos that reference the user will be dispatched
    to the user through Slack.
  """
  def insert_watched(repos) do
    Repo.insert_all(__MODULE__, repos,
                    on_conflict: :nothing,
                    conflict_target: [:user_id, :full_name])
  end

  @doc """
    Stop watching repos by the user.
    All incoming GitHub webhooks from these repos that reference the user won't be dispatched
    to the user through Slack.
  """
  def delete_unwatched(user, full_names) do
    query = from repo in __MODULE__,
            where: repo.user_id == type(^user.id, Ecto.UUID) and repo.full_name in ^full_names

    Repo.delete_all(query)
  end
end
