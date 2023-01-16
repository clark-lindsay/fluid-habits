defmodule FluidHabits.Achievements.Group do
  @moduledoc """
      Organizational category for `AchievementLevel`s

      e.g. If you have an `Activity` of "Fitness", you could have a `Group` for
      cardiovascular training and a `Group` for resistance training.
  """

  use FluidHabits.Schema
  import Ecto.Changeset

  typed_schema "achievement_groups" do
    field :description, :string
    field :name, :string, null: false

    belongs_to :activity, FluidHabits.Activities.Activity
    has_many :achievement_levels, FluidHabits.AchievementLevels.AchievementLevel

    timestamps()
  end

  @doc false
  def changeset(group, attrs) do
    group
    |> cast(attrs, [:name, :description])
    |> validate_required([:name, :description])
  end
end
