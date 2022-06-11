defmodule FluidHabits.Activities.Activity do
  use Ecto.Schema
  import Ecto.Changeset

  schema "activities" do
    field :description, :string
    field :name, :string
    belongs_to :user, FluidHabits.Accounts.User

    timestamps()
  end

  @doc false
  def changeset(activity, attrs) do
    activity
    |> cast(attrs, [:name, :description])
    |> validate_required([:name, :description])
  end
end
