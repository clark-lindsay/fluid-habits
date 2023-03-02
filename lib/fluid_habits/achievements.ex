defmodule FluidHabits.Achievements do
  @moduledoc """
  The Achievements context.
  """

  import Ecto.Query, warn: false

  alias Ecto.Multi
  alias FluidHabits.Repo
  alias FluidHabits.Achievements.{Achievement, Group}
  alias FluidHabits.Broadcasters.Broadcaster

  @doc """
  Creates an achievement.

  Requires a valid `Activity` and a valid `Achievements.Level` that the 
  achievement will be associated to.

  ## Examples

      iex> create_achievement(activity, %{field: value, activity_id: act.id, achievement_level_id: ach_lvl.id})
      {:ok, %Achievement{}}

      iex> create_achievement(activity, %{field: bad_value, activity_id: act.id, achievement_level_id: ach_lvl.id})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_achievement(map()) :: {:ok, Achievement.t()} | {:error, atom()}
  def create_achievement(attrs \\ %{}) do
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
        achievement = Repo.preload(achievement, activity: :user)

        Broadcaster.broadcast(
          FluidHabits.PubSub,
          "user:#{achievement.activity.user_id}",
          {:create_achievement,
           %{
             achievement: achievement
           }}
        )

        {:ok, achievement}

      {:error, _failed_operation, reason, _changes_so_far} ->
        {:error, reason}
    end
  end

  @doc """
    Write a new `Achievements.Group` to the database and associate any `Achievements.Level`s
    identified in the `"achievement_level"` param to the new group, replacing whatever associated
    group they might currently have.
  """
  @spec create_group(map()) :: {:ok, Group.t()} | {:error, Ecto.Changeset.t()}
  def create_group(attrs \\ %{}) do
    FluidHabits.Achievements.Group.changeset(%FluidHabits.Achievements.Group{}, attrs)
    |> Repo.insert()
  end
end
