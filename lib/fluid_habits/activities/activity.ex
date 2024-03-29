defmodule FluidHabits.Activities.Activity do
  @moduledoc false
  use FluidHabits.Schema

  import Ecto.Changeset

  typed_schema "activities" do
    field :description, :string
    field :name, :string

    belongs_to :user, FluidHabits.Accounts.User
    has_many :achievement_levels, FluidHabits.Achievements.Level
    has_many :achievements, FluidHabits.Achievements.Achievement
    has_many :achievement_groups, FluidHabits.Achievements.Group

    timestamps()
  end

  @doc false
  def changeset(activity, attrs) do
    activity
    |> cast(attrs, [:name, :description, :user_id])
    |> validate_required([:name, :description, :user_id])
    |> assoc_constraint(:user)
  end
end
