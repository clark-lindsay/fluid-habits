defmodule FluidHabits.Achievements.AchievementQueries do
  import Ecto.Query, only: [from: 2]

  def since(queryable, %NaiveDateTime{} = date_time) do
    from(ach in queryable, where: ach.inserted_at >= ^date_time)
  end

  def until(queryable, %NaiveDateTime{} = date_time) do
    from(ach in queryable, where: ach.inserted_at <= ^date_time)
  end

  def desc_by(queryable, column) do
    from(queryable, order_by: [desc: ^column])
  end

  def for_activity(queryable, %{id: activity_id} = %FluidHabits.Activities.Activity{}) do
    from(ach in queryable, where: ach.activity_id == ^activity_id)
  end

  def limit(queryable, max), do: from(queryable, limit: ^max)
end
