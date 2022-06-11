defmodule FluidHabits.Repo.Migrations.ActivityBelongsToUser do
  use Ecto.Migration

  def change do
    alter table(:activities) do
      add :user_id, references(:users)
    end
  end
end
