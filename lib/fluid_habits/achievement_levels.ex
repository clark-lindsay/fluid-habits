defmodule FluidHabits.AchievementLevels do
  @moduledoc """
  The AchievementLevels context.
  """

  import Ecto.Query, warn: false
  alias FluidHabits.Repo

  alias FluidHabits.AchievementLevels.AchievementLevel

  @doc """
  Creates an achievement_level.

  Requires a valid Activity, that the AchievementLevel will belong to.

  ## Examples

      iex> create_achievement_level(%{field: value, activity_id: activity.id})
      {:ok, %AchievementLevel{}}

      iex> create_achievement_level(%{field: bad_value, activity_id: activity.id})
      {:error, %Ecto.Changeset{}}

  """
  def create_achievement_level(attrs \\ %{}) do
    %AchievementLevel{}
    |> AchievementLevel.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a achievement_level.

  ## Examples

      iex> update_achievement_level(achievement_level, %{field: new_value})
      {:ok, %AchievementLevel{}}

      iex> update_achievement_level(achievement_level, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_achievement_level(%AchievementLevel{} = achievement_level, attrs) do
    achievement_level
    |> AchievementLevel.changeset(attrs)
    |> Repo.update()
  end
end
