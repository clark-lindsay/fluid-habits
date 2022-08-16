defmodule FluidHabits.AchievementsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `FluidHabits.Achievements` context.

  Additional "achievement levels" are added so that the Activity becomes
  "eligible" for achievements

  For more information on "eligibility", see the `Achievements` module
  """

  alias FluidHabits.{Activities, Achievements}
  alias FluidHabits.{ActivitiesFixtures, AchievementLevelsFixtures}

  @doc """
  Generate a achievement.
  """
  def achievement_fixture(attrs \\ %{}) do
    activity = attrs[:activity] || ActivitiesFixtures.activity_fixture()

    achievement_level =
      attrs[:achievement_level] ||
        AchievementLevelsFixtures.achievement_level_fixture(%{activity: activity})

    for _iteration <- Range.new(1, Activities.min_ach_levels_for_ach_eligibility()) do
      AchievementLevelsFixtures.achievement_level_fixture(%{activity: activity})
    end

    achievement_attrs =
      attrs
      |> Enum.into(%{activity_id: activity.id, achievement_level_id: achievement_level.id})

    {:ok, achievement} = Achievements.create_achievement(achievement_attrs)

    achievement
  end
end
