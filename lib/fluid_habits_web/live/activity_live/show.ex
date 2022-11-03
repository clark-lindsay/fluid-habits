defmodule FluidHabitsWeb.ActivityLive.Show do
  use FluidHabitsWeb, :live_view

  alias FluidHabits.{Accounts, Activities}
  alias Phoenix.PubSub

  @max_recent_achievements 10

  @impl Phoenix.LiveView
  def mount(_params, %{"user_token" => user_token} = _session, socket) do
    if connected?(socket) do
      PubSub.subscribe(FluidHabits.PubSub, "achievement")
      PubSub.subscribe(FluidHabits.PubSub, "achievement_metadata")
    end

    current_user = Accounts.get_user_by_session_token(user_token)

    socket = assign(socket, :current_user, current_user)
    {:ok, socket}
  end

  # TODO: investigate: is it a bad pattern to have a "live" `handle_params`
  # and a separate "dead" handle params? 
  # if the user can't establish a websocket connection, then I want the forms disabled and I don't
  # want all of the DB overhead
  @impl Phoenix.LiveView
  def handle_params(%{"id" => id}, _, socket) do
    now = Timex.now()

    one_week_ago = Timex.shift(now, days: -7)

    start_of_current_week =
      Timex.beginning_of_week(
        DateTime.shift_zone!(now, socket.assigns.current_user.timezone),
        :mon
      )

    # TODO: optimize DB access
    # _LOTS_ of non-orthogonal DB calls here
    with activity <- Activities.get_activity!(id),
         eligible_for_achievements? <- Activities.eligible_for_achievements?(activity),
         achievement_levels <- Activities.list_achievement_levels(activity),
         recent_achievements <-
           Activities.list_achievements_since(activity, one_week_ago,
             limit: @max_recent_achievements
           ),
         active_streak <- Activities.active_streak(activity),
         weekly_score <-
           Activities.sum_scores_since(
             activity,
             DateTime.shift_zone!(start_of_current_week, "Etc/UTC")
           ) do
      {:noreply,
       socket
       |> assign(:page_title, page_title(socket.assigns.live_action))
       |> assign(:activity, activity)
       |> assign(:eligible_for_achievements?, eligible_for_achievements?)
       |> assign(:achievement_levels, achievement_levels)
       |> assign(:recent_achievements, recent_achievements)
       |> assign(:active_streak, active_streak)
       |> assign(:start_of_week, start_of_current_week)
       |> assign(:weekly_score, weekly_score)}
    end
  end

  @impl Phoenix.LiveView
  def handle_event("close_modal", _, socket) do
    route_to_show = Routes.activity_show_path(socket, :show, socket.assigns.activity)

    {:noreply, push_patch(socket, to: route_to_show)}
  end

  @impl Phoenix.LiveView
  def handle_info({:create, %{achievement: %{activity: %{user: user}} = achievement}}, socket) do
    if user.id == socket.assigns.current_user.id do
      achievement = FluidHabits.Repo.preload(achievement, :achievement_level)

      recent_achievements =
        socket.assigns.recent_achievements
        |> Stream.filter(fn %{id: id} ->
          id != achievement.id
        end)
        |> Enum.take(@max_recent_achievements)

      socket = assign(socket, :recent_achievements, [achievement | recent_achievements])

      {:noreply, socket}
    else
      {:noreply, socket}
    end
  end

  @impl Phoenix.LiveView
  def handle_info({:streak_update, %{active_streak: updated_streak}}, socket) do
    socket = assign(socket, active_streak: updated_streak)

    {:noreply, socket}
  end

  defp page_title(:show), do: "Show Activity"
  defp page_title(:edit), do: "Edit Activity"
  defp page_title(:add_ach_lvl), do: "Add Achievement Level"
  defp page_title(:add_achievement), do: "Add Achievement"
end
