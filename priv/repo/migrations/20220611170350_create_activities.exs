defmodule FluidHabits.Repo.Migrations.CreateActivities do
  use Ecto.Migration

  def change do
    create table(:activities) do
      add :name, :string
      add :description, :string

      timestamps()
    end
  end
end
