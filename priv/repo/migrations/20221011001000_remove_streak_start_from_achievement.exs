defmodule FluidHabits.Repo.Migrations.RemoveStreakStartFromAchievement do
  use Ecto.Migration

  def change do
    alter table("achievements") do
      remove(:streak_start, :naive_datetime, default: fragment("NOW()"))
    end
  end
end
