defmodule FluidHabits.Repo.Migrations.AchievementLevelsBelongToAchievementGroups do
  use Ecto.Migration

  def change do
    alter table(:achievement_levels) do
      add :group_id, references(:achievement_groups)
    end
  end
end
