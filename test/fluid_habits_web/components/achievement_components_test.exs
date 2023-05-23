defmodule FluidHabitsWeb.AchievementComponentsTest do
  use FluidHabitsWeb.ConnCase, async: true

  import Phoenix.Component
  import Phoenix.LiveViewTest

  alias FluidHabits.AchievementsFixtures
  alias FluidHabitsWeb.Components.AchievementComponents

  describe "to_list_item/1" do
    setup context, do: Mox.set_mox_from_context(context)

    test "renders the name and inserted_at time for the achievement" do
      %{inserted_at: inserted_at, achievement_level: achievement_level} =
        achievement = FluidHabits.Repo.preload(AchievementsFixtures.achievement_fixture(), :achievement_level)

      assigns = %{achievement: achievement}

      html =
        rendered_to_string(~H"""
        <AchievementComponents.to_list_item achievement={@achievement} timezone="Etc/UTC" />
        """)

      assert html =~ achievement_level.name

      assert html =~
               Regex.compile!("#{inserted_at.month}.*#{inserted_at.day}")
    end
  end
end
