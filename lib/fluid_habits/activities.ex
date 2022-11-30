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

  @doc """
  Returns all activities identified by the given list of IDs.

  Raises if _all_ IDs are not found.
  """
  @spec list_activities_with_ids!(list(integer())) :: list(Activity.t())
  def list_activities_with_ids!(ids) do
    activities =
      from(act in Activity,
        where: act.id in ^ids
      )
      |> Repo.all()

    if length(ids) != length(activities) do
      raise("All IDs must be found in the database")
    else
      activities
    end
  end

  def list_achievement_levels(%Activity{id: id} = _activity) do
    Repo.all(
      from(ach_lvl in FluidHabits.AchievementLevels.AchievementLevel,
        where: ach_lvl.activity_id == ^id
      )
    )
  end

  def list_achievements_since(%Activity{} = activity, since, options \\ []) do
    alias FluidHabits.Achievements.{Achievement, AchievementQueries}

    default_options = [limit: 10, until: DateTime.utc_now()]

    options = Keyword.merge(default_options, options)

    Achievement
    |> AchievementQueries.since(since)
    |> AchievementQueries.until(options[:until])
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
      from(ach_lvl in FluidHabits.AchievementLevels.AchievementLevel,
        where: ach_lvl.activity_id == ^id
      )

    Repo.aggregate(query, :count) >= @min_ach_levels_for_ach_eligibility
  end

  @doc """
    Hits the DB to find the DateTimes representing the _first_
    `%Achievement{}` associated to the activity for the active "streak" and the
    most recent achievement in that streak. 

    A "streak" is defined as consecutive achievements (of any
    `%AchievementLevel{}`) with no more than 1 calendar day between them,
    starting from yesterday at 00:00 _for the user's timezone_. This means that
    if there is no achievement today, a user can still have an active streak as
    long as they logged an achievement yesterday.

    Returns `nil` if there is not an active streak.
  """
  @spec active_streak(Activity.t()) ::
          {:single, DateTime.t()}
          | {:range, %{required(:start) => DateTime.t(), required(:end) => DateTime.t()}}
          | nil
  def active_streak(%Activity{} = activity) do
    import Ecto.Query, only: [from: 2]

    alias FluidHabits.Achievements.Achievement
    alias FluidHabits.Accounts.User

    timezone = Repo.one(from(u in User, where: u.id == ^activity.user_id, select: u.timezone))
    yesterday_origin = Timex.now(timezone) |> Timex.shift(days: -1) |> Timex.beginning_of_day()

    {:ok, streak} =
      Repo.transaction(fn ->
        from(ach in Achievement,
          where: ach.activity_id == ^activity.id,
          order_by: [desc: ach.inserted_at],
          select: ach.inserted_at
        )
        |> Repo.stream()
        |> Stream.map(&DateTime.shift_zone!(&1, timezone))
        |> Stream.transform(yesterday_origin, fn inserted_at, day_origin ->
          if Timex.after?(inserted_at, day_origin) or
               Timex.equal?(inserted_at, day_origin, :microseconds) do
            {[inserted_at], Timex.shift(inserted_at, days: -1) |> Timex.beginning_of_day()}
          else
            {:halt, day_origin}
          end
        end)
        |> Enum.to_list()
        |> then(fn datetimes ->
          shift_zone = fn
            nil -> nil
            datetime -> DateTime.shift_zone!(datetime, "Etc/UTC")
          end

          {most_recent, tail} = List.pop_at(datetimes, 0)

          case tail do
            [] -> if is_nil(most_recent), do: nil, else: {:single, shift_zone.(most_recent)}
            _ -> {:range, %{start: shift_zone.(List.last(tail)), end: shift_zone.(most_recent)}}
          end
        end)
      end)

    streak
  end

  @doc """
    Returns the maximum `%AchievementLevel{}` `value` per day, grouped by date
    of entry, since a given datetime, localized to the user's timezone.

    Accepts the same options as `list_achievements_since/3`

    ## Examples

        iex> sum_scores_since(activity, datetime)
        [{~D(...), 2}, {~D(...), 1}]
  """

  @spec scores_since(Activity.t(), DateTime.t(), keyword()) :: keyword()
  def scores_since(activity, since, opts \\ []) do
    alias FluidHabits.{Accounts.User, Achievements.Achievement}

    timezone = Repo.one(from(u in User, where: u.id == ^activity.user_id, select: u.timezone))

    list_achievements_since(activity, since, opts)
    |> Enum.map(fn achievement = %Achievement{inserted_at: inserted_at} ->
      %{achievement | inserted_at: DateTime.shift_zone!(inserted_at, timezone)}
    end)
    |> Enum.group_by(
      fn %Achievement{inserted_at: inserted_at} -> DateTime.to_date(inserted_at) end,
      fn %Achievement{achievement_level: %{value: value}} -> value end
    )
    |> Enum.map(fn {datetime, daily_achievement_values} ->
      {datetime, Enum.max(daily_achievement_values)}
    end)
  end

  def min_ach_levels_for_ach_eligibility(), do: @min_ach_levels_for_ach_eligibility
end
