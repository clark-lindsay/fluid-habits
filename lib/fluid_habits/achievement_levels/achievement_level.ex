defmodule FluidHabits.AchievementLevels.AchievementLevel do
  use Ecto.Schema
  import Ecto.Changeset

  schema "achievement_levels" do
    field(:description, :string)
    field(:name, :string)
    field(:value, :integer)

    belongs_to(:activity, FluidHabits.Activities.Activity)

    timestamps()
  end

  @doc false
  def changeset(achievement_level, attrs) do
    achievement_level
    |> cast(attrs, [:name, :description, :value, :activity_id])
    |> validate_required([:name, :description, :value, :activity_id])
    |> validate_inclusion(:value, 1..3, message: "Must be a value from 1-3")
    |> assoc_constraint(:activity,
      message: "An achievement level must be associated to an existing activity"
    )
  end
end
