defmodule FluidHabits.Repo.Migrations.AddStreakStartToAchievement do
  use Ecto.Migration

  def change do
    alter table("achievements") do
      add(
        :streak_start,
        :naive_datetime,
        null: false,
        default: fragment("NOW()")
      )
    end
  end
end
