defmodule FluidHabits.AchievementsTest do
  use FluidHabits.DataCase, async: true

  alias FluidHabits.Achievements

  describe "achievements" do
    alias FluidHabits.Achievements.Achievement

    import FluidHabits.AchievementsFixtures

    test "list_achievements/0 returns all achievements" do
      achievement = achievement_fixture()
      assert Achievements.list_achievements() == [achievement]
    end

    test "get_achievement!/1 returns the achievement with given id" do
      achievement = achievement_fixture()
      assert Achievements.get_achievement!(achievement.id) == achievement
    end

    test "create_achievement/1 with valid data creates a achievement" do
      valid_attrs = %{}

      assert {:ok, %Achievement{}} = Achievements.create_achievement(valid_attrs)
    end

    test "update_achievement/2 with valid data updates the achievement" do
      achievement = achievement_fixture()
      update_attrs = %{}

      assert {:ok, %Achievement{}} = Achievements.update_achievement(achievement, update_attrs)
    end

    test "delete_achievement/1 deletes the achievement" do
      achievement = achievement_fixture()
      assert {:ok, %Achievement{}} = Achievements.delete_achievement(achievement)
      assert_raise Ecto.NoResultsError, fn -> Achievements.get_achievement!(achievement.id) end
    end

    test "change_achievement/1 returns a achievement changeset" do
      achievement = achievement_fixture()
      assert %Ecto.Changeset{} = Achievements.change_achievement(achievement)
    end
  end
end
