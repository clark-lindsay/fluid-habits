defmodule FluidHabits.AchievementsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `FluidHabits.Achievements` context.
  """

  @doc """
  Generate a achievement.
  """
  def achievement_fixture(attrs \\ %{}) do
    activity = attrs[:activity] || FluidHabits.ActivitiesFixtures.activity_fixture()

    achievement_level =
      attrs[:achievement_level] ||
        FluidHabits.AchievementLevelsFixtures.achievement_level_fixture(%{activity: activity})

    achievement_attrs =
      attrs
      |> Enum.into(%{achievement_level_id: achievement_level.id})

    {:ok, achievement} = FluidHabits.Achievements.create_achievement(activity, achievement_attrs)

    achievement
  end
end
