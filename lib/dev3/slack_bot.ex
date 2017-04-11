defmodule Dev3.SlackBot do
  use Ecto.Schema

  import Ecto.Changeset

  alias Dev3.Repo

  schema "slack_bots" do
    field :slack_access_token, :string
    field :slack_team_id, :string
    field :slack_user_id, :string

    timestamps()
  end

  @doc """
    Creates a new slack bot for the Slack team if none exists, or updates the access_token
    otherwise
  """
  def insert_or_update(params) do
    case Repo.get_by(__MODULE__, Map.take(params, [:slack_team_id])) do
       nil ->  create_changeset(%__MODULE__{}, params)
       user -> update_changeset(user, params)
     end
     |> Repo.insert_or_update
  end

#======= Changeset ========#

  @create_fields ~w(slack_user_id slack_team_id slack_access_token)a
  defp create_changeset(slack_bot, params) do
    slack_bot
    |> cast(params, @create_fields)
    |> validate_required(@create_fields)
  end

  @update_fields ~w(slack_access_token)a
  defp update_changeset(slack_bot, params) do
    slack_bot
    |> cast(params, @update_fields)
    |> validate_required(@update_fields)
  end
end
