defmodule FluidHabitsWeb.ActivityLive.Show do
  use FluidHabitsWeb, :live_view

  alias FluidHabits.{Accounts, Achievements, Activities}

  @max_recent_achievements 10

  @impl Phoenix.LiveView
  def mount(_params, %{"user_token" => user_token} = _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(FluidHabits.PubSub, "achievement")

      current_user = Accounts.get_user_by_session_token(user_token)

      socket = assign(socket, :current_user, current_user)

      {:ok, socket}
    else
      {:ok, socket}
    end
  end

  @impl Phoenix.LiveView
  def handle_params(%{"id" => id}, _, socket) do
    one_week_ago =
      NaiveDateTime.utc_now()
      |> Timex.add(Timex.Duration.from_days(-7))

    start_of_current_week = NaiveDateTime.utc_now() |> Timex.beginning_of_week(:mon)

    # TODO: optimize DB access
    # _LOTS_ of non-orthogonal DB calls here
    with activity <- Activities.get_activity!(id),
         eligible_for_achievements? <- Activities.eligible_for_achievements?(activity),
         achievement_levels <- Activities.list_achievement_levels(activity),
         recent_achievements <-
           Activities.list_achievements_since(activity, one_week_ago,
             limit: @max_recent_achievements
           ),
         current_week_achievements <-
           Activities.list_achievements_since(activity, start_of_current_week),
         active_streak_start <- Activities.active_streak_start(activity),
         weekly_score <- Achievements.sum_scores(current_week_achievements) do
      active_streak_start =
        case active_streak_start do
          %NaiveDateTime{} = streak_start -> NaiveDateTime.to_date(streak_start)
          _ -> "No active Streak"
        end

      {:noreply,
       socket
       |> assign(:page_title, page_title(socket.assigns.live_action))
       |> assign(:activity, activity)
       |> assign(:eligible_for_achievements?, eligible_for_achievements?)
       |> assign(:achievement_levels, achievement_levels)
       |> assign(:recent_achievements, recent_achievements)
       |> assign(:active_streak_start, active_streak_start)
       |> assign(:start_of_week, start_of_current_week |> NaiveDateTime.to_date())
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

  defp page_title(:show), do: "Show Activity"
  defp page_title(:edit), do: "Edit Activity"
  defp page_title(:add_ach_lvl), do: "Add Achievement Level"
  defp page_title(:add_achievement), do: "Add Achievement"
end
