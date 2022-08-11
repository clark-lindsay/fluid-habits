defmodule FluidHabits.AchievementLevelsTest do
  use FluidHabits.DataCase, async: true

  alias FluidHabits.AchievementLevels

  describe "achievement_levels" do
    alias FluidHabits.AchievementLevels.AchievementLevel

    import FluidHabits.AchievementLevelsFixtures

    @invalid_attrs %{description: nil, name: nil, value: nil}
    @valid_attrs %{description: "some description", name: "some name", value: 2}

    test "list_achievement_levels/0 returns all achievement_levels" do
      achievement_level = achievement_level_fixture()
      assert AchievementLevels.list_achievement_levels() == [achievement_level]
    end

    test "get_achievement_level!/1 returns the achievement_level with given id" do
      achievement_level = achievement_level_fixture()
      assert AchievementLevels.get_achievement_level!(achievement_level.id) == achievement_level
    end

    test "create_achievement_level/1 with valid data creates a achievement_level" do
      activity = FluidHabits.ActivitiesFixtures.activity_fixture()

      assert {:ok, %AchievementLevel{} = achievement_level} =
               AchievementLevels.create_achievement_level(
                 Map.put(@valid_attrs, :activity_id, activity.id)
               )

      assert achievement_level.description == "some description"
      assert achievement_level.name == "some name"
      assert achievement_level.value == 2
    end

    test "create_achievement_level/1 with invalid data returns error changeset" do
      activity = FluidHabits.ActivitiesFixtures.activity_fixture()

      assert {:error, %Ecto.Changeset{}} =
               AchievementLevels.create_achievement_level(
                 Map.put(@invalid_attrs, :activity_id, activity.id)
               )
    end

    test "create_achievement_level/1 with value < 1 or > 3 returns error changeset" do
      activity = FluidHabits.ActivitiesFixtures.activity_fixture()
      valid_attrs = Map.merge(@valid_attrs, %{activity_id: activity.id})

      assert {:error, %Ecto.Changeset{}} =
               AchievementLevels.create_achievement_level(Map.merge(valid_attrs, %{value: 0}))

      assert {:error, %Ecto.Changeset{}} =
               AchievementLevels.create_achievement_level(Map.merge(valid_attrs, %{value: 4}))
    end

    test "create_achievement_level/1 with non-integer value returns error changeset" do
      activity = FluidHabits.ActivitiesFixtures.activity_fixture()
      valid_attrs = Map.merge(@valid_attrs, %{activity_id: activity.id})

      assert {:error, %Ecto.Changeset{}} =
               AchievementLevels.create_achievement_level(Map.merge(valid_attrs, %{value: 2.5}))
    end

    test "update_achievement_level/2 with valid data updates the achievement_level" do
      achievement_level = achievement_level_fixture()

      update_attrs = %{
        description: "some updated description",
        name: "some updated name",
        value: 3
      }

      assert {:ok, %AchievementLevel{} = achievement_level} =
               AchievementLevels.update_achievement_level(achievement_level, update_attrs)

      assert achievement_level.description == "some updated description"
      assert achievement_level.name == "some updated name"
      assert achievement_level.value == 3
    end

    test "update_achievement_level/2 with invalid data returns error changeset" do
      achievement_level = achievement_level_fixture()

      assert {:error, %Ecto.Changeset{}} =
               AchievementLevels.update_achievement_level(achievement_level, @invalid_attrs)

      assert achievement_level == AchievementLevels.get_achievement_level!(achievement_level.id)
    end

    test "delete_achievement_level/1 deletes the achievement_level" do
      achievement_level = achievement_level_fixture()

      assert {:ok, %AchievementLevel{}} =
               AchievementLevels.delete_achievement_level(achievement_level)

      assert_raise Ecto.NoResultsError, fn ->
        AchievementLevels.get_achievement_level!(achievement_level.id)
      end
    end

    test "change_achievement_level/1 returns a achievement_level changeset" do
      achievement_level = achievement_level_fixture()
      assert %Ecto.Changeset{} = AchievementLevels.change_achievement_level(achievement_level)
    end
  end
end
