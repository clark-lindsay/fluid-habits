defmodule FluidHabitsWeb.ActivityLive.Show do
  use FluidHabitsWeb, :live_view

  alias FluidHabits.{Activities}

  @day_in_seconds 60 * 60 * 24

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl Phoenix.LiveView
  def handle_params(%{"id" => id}, _, socket) do
    activity = Activities.get_activity!(id)
    achievement_levels = Activities.list_achievement_levels(activity)

    one_week_ago =
      NaiveDateTime.utc_now()
      |> NaiveDateTime.add(-7 * @day_in_seconds, :second)

    recent_achievements = Activities.list_achievements_since(activity, one_week_ago)

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:activity, activity)
     |> assign(:achievement_levels, achievement_levels)
     |> assign(:recent_achievements, recent_achievements)}
  end

  @impl Phoenix.LiveView
  def handle_event("close_modal", _, socket) do
    route_to_show = Routes.activity_show_path(socket, :show, socket.assigns.activity)

    {:noreply, push_patch(socket, to: route_to_show)}
  end

  defp page_title(:show), do: "Show Activity"
  defp page_title(:edit), do: "Edit Activity"
  defp page_title(:add_ach_lvl), do: "Add Achievement Level"
  defp page_title(:add_achievement), do: "Add Achievement"
end
