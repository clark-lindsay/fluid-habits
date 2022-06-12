defmodule FluidHabits.AchievementLevels do
  @moduledoc """
  The AchievementLevels context.
  """

  import Ecto.Query, warn: false
  alias FluidHabits.{Repo, Activities}

  alias FluidHabits.AchievementLevels.AchievementLevel

  @doc """
  Returns the list of achievement_levels.

  ## Examples

      iex> list_achievement_levels()
      [%AchievementLevel{}, ...]

  """
  def list_achievement_levels do
    Repo.all(AchievementLevel)
  end

  @doc """
  Gets a single achievement_level.

  Raises `Ecto.NoResultsError` if the Achievement level does not exist.

  ## Examples

      iex> get_achievement_level!(123)
      %AchievementLevel{}

      iex> get_achievement_level!(456)
      ** (Ecto.NoResultsError)

  """
  def get_achievement_level!(id), do: Repo.get!(AchievementLevel, id)

  @doc """
  Creates a achievement_level.

  ## Examples

      iex> create_achievement_level(%{field: value})
      {:ok, %AchievementLevel{}}

      iex> create_achievement_level(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_achievement_level(%Activities.Activity{} = activity, attrs \\ %{}) do
    activity
    |> Ecto.build_assoc(:achievement_levels, %AchievementLevel{})
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

  @doc """
  Deletes a achievement_level.

  ## Examples

      iex> delete_achievement_level(achievement_level)
      {:ok, %AchievementLevel{}}

      iex> delete_achievement_level(achievement_level)
      {:error, %Ecto.Changeset{}}

  """
  def delete_achievement_level(%AchievementLevel{} = achievement_level) do
    Repo.delete(achievement_level)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking achievement_level changes.

  ## Examples

      iex> change_achievement_level(achievement_level)
      %Ecto.Changeset{data: %AchievementLevel{}}

  """
  def change_achievement_level(%AchievementLevel{} = achievement_level, attrs \\ %{}) do
    AchievementLevel.changeset(achievement_level, attrs)
  end
end
