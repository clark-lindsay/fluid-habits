defmodule FluidHabits.Achievements.AchievementQueries do
  @moduledoc """
  Composable functions for building queries to retrieve
  information information related to `Achievement`s from the DB
  """

  import Ecto.Query, only: [from: 2]

  def since(queryable, %DateTime{} = date_time) do
    date_time = DateTime.shift_zone!(date_time, "Etc/UTC")

    from(ach in queryable, where: ach.inserted_at >= ^date_time)
  end

  def until(queryable, %DateTime{} = date_time) do
    date_time = DateTime.shift_zone!(date_time, "Etc/UTC")

    from(ach in queryable, where: ach.inserted_at <= ^date_time)
  end

  def desc_by(queryable, column) do
    from(queryable, order_by: [desc: ^column])
  end

  def for_activity(queryable, %{id: activity_id} = %FluidHabits.Activities.Activity{}) do
    from(ach in queryable, where: ach.activity_id == ^activity_id)
  end

  def limit(queryable, :infinity), do: queryable
  def limit(queryable, max), do: from(queryable, limit: ^max)
end
