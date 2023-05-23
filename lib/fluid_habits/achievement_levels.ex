defmodule FluidHabits.AchievementLevels do
  @moduledoc """
  The `Achievements.Level`s context.
  """

  import Ecto.Query, warn: false

  alias FluidHabits.Achievements.Level
  alias FluidHabits.Repo

  @doc """
  Creates an `Achievements.Level`

  Requires a valid Activity, that the Level will belong to.

  ## Examples

      iex> create_achievement_level(%{field: value, activity_id: activity.id})
      {:ok, %Achievements.Level{}}

      iex> create_achievement_level(%{field: bad_value, activity_id: activity.id})
      {:error, %Ecto.Changeset{}}

  """
  def create_achievement_level(attrs \\ %{}) do
    %Level{}
    |> Level.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a achievement_level.

  ## Examples

      iex> update_achievement_level(achievement_level, %{field: new_value})
      {:ok, %Level{}}

      iex> update_achievement_level(achievement_level, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_achievement_level(%Level{} = achievement_level, attrs) do
    achievement_level
    |> Level.changeset(attrs)
    |> Repo.update()
  end
end
