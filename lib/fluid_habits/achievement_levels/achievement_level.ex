defmodule FluidHabits.AchievementLevels.AchievementLevel do
  use Ecto.Schema
  import Ecto.Changeset

  schema "achievement_levels" do
    field :description, :string
    field :name, :string
    field :value, :integer

    timestamps()
  end

  @doc false
  def changeset(achievement_level, attrs) do
    achievement_level
    |> cast(attrs, [:name, :description, :value])
    |> validate_required([:name, :description, :value])
  end
end
