defmodule FluidHabits.Achievements do
  @moduledoc """
  The Achievements context.
  """

  import Ecto.Query, warn: false
  alias FluidHabits.Repo

  alias FluidHabits.Achievements.Achievement

  @doc """
  Returns the list of achievements.

  ## Examples

      iex> list_achievements()
      [%Achievement{}, ...]

  """
  def list_achievements do
    Repo.all(Achievement)
  end

  @doc """
  Gets a single achievement.

  Raises `Ecto.NoResultsError` if the Achievement does not exist.

  ## Examples

      iex> get_achievement!(123)
      %Achievement{}

      iex> get_achievement!(456)
      ** (Ecto.NoResultsError)

  """
  def get_achievement!(id), do: Repo.get!(Achievement, id)

  @doc """
  Creates an achievement.

  Requires a valid Activity and a valid AchievementLevel that the achievement will relate to.

  ## Examples

      iex> create_achievement(activity, %{field: value, activity_id: act.id, achievement_level_id: ach_lvl.id})
      {:ok, %Achievement{}}

      iex> create_achievement(activity, %{field: bad_value, activity_id: act.id, achievement_level_id: ach_lvl.id})
      {:error, %Ecto.Changeset{}}

  """
  def create_achievement(attrs \\ %{}) do
    Achievement.changeset(%Achievement{}, attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a achievement.

  ## Examples

      iex> update_achievement(achievement, %{field: new_value})
      {:ok, %Achievement{}}

      iex> update_achievement(achievement, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_achievement(%Achievement{} = achievement, attrs) do
    achievement
    |> Achievement.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a achievement.

  ## Examples

      iex> delete_achievement(achievement)
      {:ok, %Achievement{}}

      iex> delete_achievement(achievement)
      {:error, %Ecto.Changeset{}}

  """
  def delete_achievement(%Achievement{} = achievement) do
    Repo.delete(achievement)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking achievement changes.

  ## Examples

      iex> change_achievement(achievement)
      %Ecto.Changeset{data: %Achievement{}}

  """
  def change_achievement(%Achievement{} = achievement, attrs \\ %{}) do
    Achievement.changeset(achievement, attrs)
  end
end
