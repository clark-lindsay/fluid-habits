defmodule FluidHabits.Repo.Migrations.AchievementsBelongToActivities do
  use Ecto.Migration

  def change do
    alter table(:achievements) do
      add :activity_id, references(:activities)
    end
  end
end
