defmodule FluidHabitsWeb.AchievementLevelComponentsTest do
  use FluidHabitsWeb.ConnCase, async: true

  import Phoenix.Component
  import Phoenix.LiveViewTest

  alias FluidHabitsWeb.Components.AchievementLevelComponents
  alias FluidHabits.AchievementLevelsFixtures

  describe "to_list_item/1" do
    test "renders the name and description time for the achievement_level" do
      achievement_level = AchievementLevelsFixtures.achievement_level_fixture()

      assigns = %{achievement_level: achievement_level}

      as_string =
        rendered_to_string(~H"""
        <AchievementLevelComponents.to_list_item ach_lvl={@achievement_level} />
        """)

      for data_point <- [achievement_level.name, achievement_level.description] do
        assert as_string =~ data_point
      end
    end
  end
end
