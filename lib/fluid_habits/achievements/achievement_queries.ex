defmodule FluidHabits.Achievements.AchievementQueries do
  import Ecto.Query, only: [from: 2]

  def since(queryable, date_time = %NaiveDateTime{}) do
    from(ach in queryable, where: ach.inserted_at > ^date_time)
  end

  def desc_by(queryable, column) do
    from(queryable, order_by: [desc: ^column])
  end
end
