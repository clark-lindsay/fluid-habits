defmodule FluidHabits.Achievements.Achievement do
  use Ecto.Schema
  import Ecto.Changeset

  schema "achievements" do
    timestamps()
  end

  @doc false
  def changeset(achievement, attrs) do
    achievement
    |> cast(attrs, [])
    |> validate_required([])
  end
end
