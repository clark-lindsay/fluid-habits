defmodule FluidHabits.AchievementLevelsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `FluidHabits.AchievementLevels` context.
  """

  @doc """
  Generate a achievement_level.
  """
  def achievement_level_fixture(attrs \\ %{}) do
    {:ok, achievement_level} =
      attrs
      |> Enum.into(%{
        description: "some description",
        name: "some name",
        value: 42
      })
      |> FluidHabits.AchievementLevels.create_achievement_level()

    achievement_level
  end
end
