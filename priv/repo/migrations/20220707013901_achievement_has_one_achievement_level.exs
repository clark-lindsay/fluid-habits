defmodule FluidHabits.Repo.Migrations.AchievementHasOneAchievementLevel do
  use Ecto.Migration

  def change do
    alter table(:achievements) do
      add :achievement_level_id, references(:achievement_levels)
    end
  end
end
