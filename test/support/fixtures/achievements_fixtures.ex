defmodule FluidHabits.AchievementsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `FluidHabits.Achievements` context.
  """

  @doc """
  Generate a achievement.
  """
  def achievement_fixture(attrs \\ %{}) do
    activity = FluidHabits.ActivitiesFixtures.activity_fixture()

    achievement_attrs =
      attrs
      |> Enum.into(%{})

    {:ok, achievement} = FluidHabits.Achievements.create_achievement(activity, achievement_attrs)

    achievement
  end
end
