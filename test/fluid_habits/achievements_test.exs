defmodule FluidHabits.AchievementsTest do
  use FluidHabits.DataCase, async: true

  alias FluidHabits.Achievements

  describe "achievements" do
    alias FluidHabits.Achievements.Achievement

    import FluidHabits.AchievementsFixtures

    setup do
      activity = FluidHabits.ActivitiesFixtures.activity_fixture()

      achievement_level =
        FluidHabits.AchievementLevelsFixtures.achievement_level_fixture(%{activity: activity})

      %{activity: activity, achievement_level: achievement_level}
    end

    test "list_achievements/0 returns all achievements",
         %{activity: _, achievement_level: _} = context do
      achievement = achievement_fixture(context)

      assert Achievements.list_achievements() == [achievement]
    end

    test "get_achievement!/1 returns the achievement with given id",
         %{achievement_level: _, activity: _} = context do
      achievement = achievement_fixture(context)

      assert Achievements.get_achievement!(achievement.id) == achievement
    end

    test "create_achievement/1 with valid data creates a achievement",
         %{achievement_level: achievement_level, activity: activity} do
      valid_attrs = %{achievement_level_id: achievement_level.id, activity_id: activity.id}

      assert {:ok, %Achievement{}} = Achievements.create_achievement(valid_attrs)
    end

    test "update_achievement/2 with valid data updates the achievement",
         %{achievement_level: _, activity: _} = context do
      achievement = achievement_fixture(context)
      update_attrs = %{}

      assert {:ok, %Achievement{}} = Achievements.update_achievement(achievement, update_attrs)
    end

    test "delete_achievement/1 deletes the achievement",
         %{achievement_level: _, activity: _} = context do
      achievement = achievement_fixture(context)

      assert {:ok, %Achievement{}} = Achievements.delete_achievement(achievement)
      assert_raise Ecto.NoResultsError, fn -> Achievements.get_achievement!(achievement.id) end
    end

    test "change_achievement/1 returns a achievement changeset",
         %{achievement_level: _, activity: _} = context do
      achievement = achievement_fixture(context)

      assert %Ecto.Changeset{} = Achievements.change_achievement(achievement)
    end
  end
end
