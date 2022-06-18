defmodule FluidHabits.AchievementLevelsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `FluidHabits.AchievementLevels` context.
  """

  alias FluidHabits.ActivitiesFixtures

  @doc """
  Generate a achievement_level.
  """
  def achievement_level_fixture(attrs \\ %{}) do
    activity = attrs[:activity] || ActivitiesFixtures.activity_fixture()

    achievement_level_attrs =
      attrs
      |> Enum.into(%{
        description: "some description",
        name: "some name",
        value: 2
      })

    {:ok, achievement_level} =
      FluidHabits.AchievementLevels.create_achievement_level(activity, achievement_level_attrs)

    achievement_level
  end
end
