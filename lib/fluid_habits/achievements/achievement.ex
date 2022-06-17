defmodule FluidHabits.Achievements.Achievement do
  use Ecto.Schema
  import Ecto.Changeset

  schema "achievements" do
    timestamps()

    belongs_to :activity, FluidHabits.Activities.Activity
  end

  @doc false
  def changeset(achievement, attrs) do
    achievement
    |> cast(attrs, [])
    |> validate_required([:activity_id])
    |> assoc_constraint(:activity,
      message: "An achievement must be associated to an existing activity"
    )
  end
end
