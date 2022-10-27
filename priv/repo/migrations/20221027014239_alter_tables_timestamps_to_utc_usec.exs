defmodule FluidHabits.Repo.Migrations.AlterTablesTimestampsToUtcUsec do
  use Ecto.Migration

  def change do
    ~w[activities achievements achievement_levels users]
    |> Enum.each(fn table_name ->
      alter table(table_name) do
        modify(
          :inserted_at,
          :utc_datetime_usec,
          from: :naive_datetime,
          null: false
        )

        modify(
          :updated_at,
          :utc_datetime_usec,
          from: :naive_datetime,
          null: false
        )
      end
    end)
  end
end
