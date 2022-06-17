defmodule FluidHabits.Repo.Migrations.CreateAchievements do
  use Ecto.Migration

  def change do
    create table(:achievements) do
      timestamps()
    end
  end
end
