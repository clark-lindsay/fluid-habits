defmodule FluidHabits.Activities do
  @moduledoc """
  The Activities context.
  """

  import Ecto.Query, warn: false
  alias FluidHabits.Repo

  alias FluidHabits.Activities.Activity
  alias FluidHabits.Accounts.User

  @min_ach_levels_for_ach_eligibility 3

  @doc """
  Returns the list of activities.

  ## Examples

      iex> list_activities()
      [%Activity{}, ...]

  """
  def list_activities do
    Repo.all(Activity)
  end

  def list_achievement_levels(%Activity{id: id} = _activity) do
    Repo.all(
      from ach_lvl in FluidHabits.AchievementLevels.AchievementLevel,
        where: ach_lvl.activity_id == ^id
    )
  end

  def list_achievements_since(activity = %Activity{}, since, options \\ []) do
    alias FluidHabits.Achievements.{Achievement, AchievementQueries}

    default_options = [limit: 10]
    options = Keyword.merge(default_options, options)

    Achievement
    |> AchievementQueries.since(since)
    |> AchievementQueries.desc_by(:inserted_at)
    |> AchievementQueries.limit(options[:limit])
    |> AchievementQueries.for_activity(activity)
    |> Repo.all()
    |> Repo.preload(:achievement_level)
  end

  @doc """
  Gets a single activity.

  Raises `Ecto.NoResultsError` if the Activity does not exist.

  ## Examples

      iex> get_activity!(123)
      %Activity{}

      iex> get_activity!(456)
      ** (Ecto.NoResultsError)

  """
  def get_activity!(id), do: Repo.get!(Activity, id)

  @doc """
  Creates a activity.

  Requires a valid user, that the activity will belong to.

  ## Examples

      iex> create_activity(user, %{field: value})
      {:ok, %Activity{}}

      iex> create_activity(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_activity(%User{} = user, attrs \\ %{}) do
    user
    |> Ecto.build_assoc(:activities, %Activity{})
    |> Activity.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a activity.

  ## Examples

      iex> update_activity(activity, %{field: new_value})
      {:ok, %Activity{}}

      iex> update_activity(activity, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_activity(%Activity{} = activity, attrs) do
    activity
    |> Activity.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a activity.

  ## Examples

      iex> delete_activity(activity)
      {:ok, %Activity{}}

      iex> delete_activity(activity)
      {:error, %Ecto.Changeset{}}

  """
  def delete_activity(%Activity{} = activity) do
    Repo.delete(activity)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking activity changes.

  ## Examples

      iex> change_activity(activity)
      %Ecto.Changeset{data: %Activity{}}

  """
  def change_activity(%Activity{} = activity, attrs \\ %{}) do
    Activity.changeset(activity, attrs)
  end

  @doc """
  Checks that there are 3 or more `%FluidHabits.AchievementLevels.AchievementLevel{}`-s
  associated with the given activity
  """
  def eligible_for_achievements?(%{id: id}) do
    import Ecto.Query, only: [from: 2]

    query =
      from ach_lvl in FluidHabits.AchievementLevels.AchievementLevel,
        where: ach_lvl.activity_id == ^id

    Repo.aggregate(query, :count) >= @min_ach_levels_for_ach_eligibility
  end

  def min_ach_levels_for_ach_eligibility(), do: @min_ach_levels_for_ach_eligibility
end
