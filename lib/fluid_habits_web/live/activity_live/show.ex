defmodule FluidHabitsWeb.ActivityLive.Show do
  use FluidHabitsWeb, :live_view

  alias FluidHabits.Activities
  alias FluidHabits.AchievementLevels.AchievementLevel

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    activity = Activities.get_activity!(id)

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:activity, activity)
     |> assign(
       :achievement_levels,
       Activities.list_achievement_levels(activity)
       |> Enum.map(fn %AchievementLevel{} = ach_lvl ->
         [key: ach_lvl.name, value: ach_lvl.id]
       end)
     )}
  end

  defp page_title(:show), do: "Show Activity"
  defp page_title(:edit), do: "Edit Activity"
  defp page_title(:add_ach_lvl), do: "Add Achievement Level"
  defp page_title(:add_achievement), do: "Add Achievement"
end
