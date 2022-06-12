defmodule FluidHabits.Repo.Migrations.AchievementLevelBelongsToActivity do
  use Ecto.Migration

  def change do
    alter table(:achievement_levels) do
      add :activity_id, references(:activities)
    end
  end
end
