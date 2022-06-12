defmodule FluidHabits.Repo.Migrations.CreateAchievementLevels do
  use Ecto.Migration

  def change do
    create table(:achievement_levels) do
      add :name, :string
      add :description, :string
      add :value, :integer

      timestamps()
    end
  end
end
