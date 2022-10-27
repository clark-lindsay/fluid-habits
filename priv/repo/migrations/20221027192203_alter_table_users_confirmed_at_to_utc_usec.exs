defmodule FluidHabits.Repo.Migrations.AlterTableUsersConfirmedAtToUtcUsec do
  use Ecto.Migration

  def change do
    alter table("users") do
      modify(
        :confirmed_at,
        :utc_datetime_usec,
        from: :naive_datetime
      )
    end
  end
end
