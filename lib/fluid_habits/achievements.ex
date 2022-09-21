defmodule FluidHabits.Achievements do
  @moduledoc """
  The Achievements context.
  """

  import Ecto.Query, warn: false

  alias Ecto.Multi
  alias FluidHabits.Repo
  alias FluidHabits.Achievements.Achievement

  @doc """
  Returns the list of achievements.

  ## Examples

      iex> list_achievements()
      [%Achievement{}, ...]

  """
  def list_achievements() do
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
  @spec create_achievement(map()) :: {:ok, %Achievement{}} | {:error, atom()}
  def create_achievement(attrs \\ %{}) do
    # get yesterday at 00:00 and today at 00:00 and search in between
    yesterday_origin =
      NaiveDateTime.utc_now()
      |> NaiveDateTime.add(60 * 60 * 24 * -1)
      |> NaiveDateTime.to_date()
      |> NaiveDateTime.new!(~T[00:00:00.000])

    today_origin =
      NaiveDateTime.utc_now()
      |> NaiveDateTime.to_date()
      |> NaiveDateTime.new!(~T[00:00:00.000])

    import Ecto.Query, only: [from: 2]

    activity_id = attrs[:activity_id] || attrs["activity_id"]

    yesterday_achievements =
      from(a in Achievement,
        where:
          a.inserted_at >= ^yesterday_origin and
            a.inserted_at < ^today_origin and
            a.activity_id == ^activity_id
      )
      |> Repo.all()

    oldest_streak =
      Enum.reduce(yesterday_achievements, NaiveDateTime.utc_now(), fn achievement, acc ->
        if NaiveDateTime.compare(acc, achievement.streak_start) == :gt do
          achievement.streak_start
        else
          acc
        end
      end)

    attrs =
      Map.to_list(attrs)
      |> Enum.map(fn
        {key, val} when is_binary(key) -> {String.to_atom(key), val}
        {key, val} when is_atom(key) -> {key, val}
      end)
      |> Map.new()
      |> Map.put_new(:streak_start, oldest_streak)

    changeset = Achievement.changeset(%Achievement{}, attrs)

    Multi.new()
    |> Multi.insert(:achievement_insert, changeset)
    |> Multi.run(:is_activity_eligible, fn _repo,
                                           %{achievement_insert: %{activity_id: activity_id}} ->
      if FluidHabits.Activities.eligible_for_achievements?(%{id: activity_id}) do
        {:ok, true}
      else
        {:error, :ineligible_for_achievements}
      end
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{achievement_insert: achievement}} ->
        {:ok, achievement}

      {:error, _failed_operation, {_, reason}, _changes_so_far} ->
        {:error, reason}
    end
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
