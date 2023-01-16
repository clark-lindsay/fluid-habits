defmodule FluidHabits.Repo.Migrations.CreateAchievementGroups do
  use Ecto.Migration

  def change do
    create table(:achievement_groups) do
      add :name, :string, null: false
      add :description, :string

      timestamps()
    end
  end
end
