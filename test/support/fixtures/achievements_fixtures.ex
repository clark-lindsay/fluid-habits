defmodule FluidHabits.AchievementsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `FluidHabits.Achievements` context.
  """

  @doc """
  Generate a achievement.
  """
  def achievement_fixture(attrs \\ %{}) do
    {:ok, achievement} =
      attrs
      |> Enum.into(%{})
      |> FluidHabits.Achievements.create_achievement()

    achievement
  end
end
