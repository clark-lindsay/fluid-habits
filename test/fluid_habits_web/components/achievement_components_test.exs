defmodule FluidHabitsWeb.AchievementComponentsTest do
  use FluidHabitsWeb.ConnCase, async: true

  import Phoenix.LiveView.Helpers
  import Phoenix.LiveViewTest

  alias FluidHabitsWeb.Components.AchievementComponents
  alias FluidHabits.AchievementsFixtures

  describe "to_list_item/1" do
    setup context, do: Mox.set_mox_from_context(context)

    test "renders the name and inserted_at time for the achievement" do
      %{inserted_at: inserted_at, achievement_level: achievement_level} =
        achievement =
        AchievementsFixtures.achievement_fixture() |> FluidHabits.Repo.preload(:achievement_level)

      assigns = []

      html =
        rendered_to_string(~H"""
        <AchievementComponents.to_list_item achievement={achievement} timezone="Etc/UTC" />
        """)

      assert html =~ achievement_level.name

      assert html =~
               Regex.compile!("#{inserted_at.month}.*#{inserted_at.day}")
    end
  end
end
