defmodule FluidHabits.Achievements.Achievement do
  use Ecto.Schema
  import Ecto.Changeset

  schema "achievements" do
    timestamps()

    belongs_to :activity, FluidHabits.Activities.Activity
    belongs_to :achievement_level, FluidHabits.AchievementLevels.AchievementLevel
  end

  def changeset(achievement, attrs) do
    achievement
    # allowing `:inserted_at` in the cast to allow for "streak" testing
    |> cast(attrs, [:achievement_level_id, :activity_id, :inserted_at])
    |> validate_required([:activity_id, :achievement_level_id])
    |> assoc_constraint(:activity,
      message: "An achievement must be associated to an existing activity"
    )
    |> assoc_constraint(:achievement_level,
      message: "An achievement must be associated to an existing achievement level"
    )
  end
end
