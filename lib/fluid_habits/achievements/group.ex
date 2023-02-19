defmodule FluidHabits.Achievements.Group do
  @moduledoc """
      Organizational category for `AchievementLevel`s

      e.g. If you have an `Activity` of "Fitness", you could have a `Group` for
      cardiovascular training and a `Group` for resistance training.
  """

  use FluidHabits.Schema
  import Ecto.Changeset

  typed_schema "achievement_groups" do
    field(:description, :string)
    field(:name, :string, null: false)

    belongs_to(:activity, FluidHabits.Activities.Activity)
    has_many(:achievement_levels, FluidHabits.Achievements.AchievementLevel)

    timestamps()
  end

  @doc false
  def changeset(group, attrs) do
    ach_lvls = attrs["achievement_levels"] || attrs[:achievement_levels] || []

    group
    |> cast(attrs, [:name, :description, :activity_id])
    |> put_assoc(:achievement_levels, ach_lvls)
    |> validate_required([:name, :description, :activity_id])
    |> validate_length(:achievement_levels, min: 1)
  end
end
