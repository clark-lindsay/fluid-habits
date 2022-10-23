defmodule FluidHabitsWeb.AchievementComponentsTest do
  use FluidHabitsWeb.ConnCase, async: true

  import Phoenix.LiveView.Helpers
  import Phoenix.LiveViewTest

  alias FluidHabitsWeb.Components.AchievementComponents
  alias FluidHabits.AchievementsFixtures

  describe "to_list_item/1" do
    setup context, do: Mox.set_mox_from_context(context)

    test "renders the name and inserted_at time for the achievement" do
      achievement =
        AchievementsFixtures.achievement_fixture() |> FluidHabits.Repo.preload(:achievement_level)

      assigns = []

      as_string =
        rendered_to_string(~H"""
        <AchievementComponents.to_list_item achievement={achievement} />
        """)

      assert as_string =~ achievement.achievement_level.name
      assert as_string =~ NaiveDateTime.to_string(achievement.inserted_at)
    end
  end
end
