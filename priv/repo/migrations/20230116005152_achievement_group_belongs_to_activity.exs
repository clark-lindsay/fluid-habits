defmodule FluidHabits.Repo.Migrations.AchievementGroupBelongsToActivity do
  use Ecto.Migration

  def change do
    alter table(:achievement_groups) do
      add :activity_id, references(:activities)
    end
  end
end
