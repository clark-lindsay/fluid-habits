defmodule FluidHabitsWeb.ActivityLiveTest do
  use FluidHabitsWeb.ConnCase, async: false

  import FluidHabits.ActivitiesFixtures
  import Mox
  import Phoenix.LiveViewTest

  @create_attrs %{description: "some description", name: "some name"}
  @update_attrs %{description: "some updated description", name: "some updated name"}
  @invalid_attrs %{description: nil, name: nil}

  defp create_activity(_) do
    activity = activity_fixture()
    %{activity: activity}
  end

  describe "Index" do
    setup [:create_activity, :register_and_log_in_user]

    test "lists all activities", %{conn: conn, activity: activity} do
      {:ok, _index_live, html} = live(conn, Routes.activity_index_path(conn, :index))

      assert html =~ "Listing Activities"
      assert html =~ activity.description
    end

    test "saves new activity", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.activity_index_path(conn, :index))

      assert index_live |> element("a", "New Activity") |> render_click() =~
               "New Activity"

      assert_patch(index_live, Routes.activity_index_path(conn, :new))

      assert index_live
             |> form("#activity-form", activity: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#activity-form", activity: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.activity_index_path(conn, :index))

      assert html =~ "Activity created successfully"
      assert html =~ "some description"
    end

    test "updates activity in listing", %{conn: conn, activity: activity} do
      {:ok, index_live, _html} = live(conn, Routes.activity_index_path(conn, :index))

      assert index_live
             |> element("#activity-#{activity.id} a", ~r/^\s+Edit\s+$/)
             |> render_click() =~
               "Edit Activity"

      assert_patch(index_live, Routes.activity_index_path(conn, :edit, activity))

      assert index_live
             |> form("#activity-form", activity: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#activity-form", activity: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.activity_index_path(conn, :index))

      assert html =~ "Activity updated successfully"
      assert html =~ "some updated description"
    end

    test "deletes activity in listing", %{conn: conn, activity: activity} do
      {:ok, index_live, _html} = live(conn, Routes.activity_index_path(conn, :index))

      assert index_live
             |> element("#activity-#{activity.id} button", ~r/^\s+Delete\s+$/)
             |> render_click()

      refute has_element?(index_live, "#activity-#{activity.id}")
    end
  end

  describe "Show" do
    setup [:create_activity, :register_and_log_in_user]
    setup [:set_mox_from_context, :verify_on_exit!]

    test "displays activity", %{conn: conn, activity: activity} do
      {:ok, _show_live, html} = live(conn, Routes.activity_show_path(conn, :show, activity))

      assert html =~ "Show Activity"
      assert html =~ activity.name
    end

    test "updates activity within modal", %{conn: conn, activity: activity} do
      {:ok, show_live, _html} = live(conn, Routes.activity_show_path(conn, :show, activity))

      assert show_live
             |> element("[href=\"/activities/#{activity.id}/show/edit\"]")
             |> render_click() =~
               "Edit Activity"

      assert_patch(show_live, Routes.activity_show_path(conn, :edit, activity))

      assert show_live
             |> form("#activity-form", activity: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#activity-form", activity: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.activity_show_path(conn, :show, activity))

      assert html =~ "Activity updated successfully"
      assert html =~ @update_attrs.name
    end

    test "adds new achievement level with modal", %{conn: conn, activity: activity} do
      {:ok, show_live, _html} = live(conn, Routes.activity_show_path(conn, :show, activity))

      assert show_live |> element("a", "Add Achievement Level") |> render_click() =~
               "Add Achievement Level"

      assert_patch(show_live, Routes.activity_show_path(conn, :add_ach_lvl, activity))

      {:ok, _live_view, html} =
        show_live
        |> form("#achievement-level-form",
          achievement_level: %{description: "some description", name: "some name", value: 1}
        )
        |> render_submit()
        |> follow_redirect(conn, Routes.activity_show_path(conn, :show, activity))

      assert html =~ "Achievement Level created successfully"
    end

    test "adds new achievement with modal", %{conn: conn, activity: activity} do
      alias FluidHabits.{Activities, AchievementLevelsFixtures}
      ref = make_ref()
      test_pid = self()

      Mox.expect(FluidHabits.Broadcasters.MockBroadcaster, :broadcast, 1, fn _, _, _ ->
        send(test_pid, {:broadcast, ref})

        :ok
      end)

      achievement_level =
        AchievementLevelsFixtures.achievement_level_fixture(%{activity: activity})

      for _iteration <- Range.new(1, Activities.min_ach_levels_for_ach_eligibility()) do
        AchievementLevelsFixtures.achievement_level_fixture(%{activity: activity})
      end

      {:ok, show_live, html} = live(conn, Routes.activity_show_path(conn, :show, activity))

      refute Floki.parse_document!(html)
             |> Floki.find("span")
             |> Floki.text() =~ achievement_level.name

      assert show_live |> element("a", ~r/^\s+Add Achievement\s+$/) |> render_click() =~
               "Add Achievement"

      assert_patch(show_live, Routes.activity_show_path(conn, :add_achievement, activity))

      show_live
      |> form("#achievement-form",
        achievement: %{achievement_level_id: achievement_level.id}
      )
      |> render_submit()

      assert_patch(show_live, Routes.activity_show_path(conn, :show, activity))

      assert render(show_live) =~ "Achievement created successfully"
      assert_receive({:broadcast, ^ref})
    end

    test "disables the button to add achievements when the activity is ineligible for them", %{
      conn: conn,
      activity: activity
    } do
      {:ok, _live, html} = live(conn, Routes.activity_show_path(conn, :show, activity))

      add_achievement_button =
        Floki.parse_document!(html)
        |> Floki.find("a")
        |> Enum.filter(fn elem ->
          Regex.match?(~r/^\s*Add\s+Achievement\s*$/, Floki.text(elem))
        end)
        |> hd()

      refute Enum.empty?(Floki.attribute(add_achievement_button, "disabled"))
    end
  end
end
