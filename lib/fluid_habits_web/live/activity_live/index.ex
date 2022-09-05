defmodule FluidHabitsWeb.ActivityLive.Index do
  use FluidHabitsWeb, :live_view

  alias FluidHabits.Activities
  alias FluidHabits.Activities.Activity

  @impl true
  def mount(_params, session, socket) do
    # get user by session token, store in socket

    user = FluidHabits.Accounts.get_user_by_session_token(session["user_token"])

    {:ok,
     assign(socket,
       activities: list_activities(),
       current_user: user
     )}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Activity")
    |> assign(:activity, Activities.get_activity!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Activity")
    |> assign(:activity, %Activity{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Activities")
    |> assign(:activity, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    activity = Activities.get_activity!(id)
    {:ok, _} = Activities.delete_activity(activity)

    {:noreply, assign(socket, :activities, list_activities())}
  end

  @impl Phoenix.LiveView
  def handle_event("close_modal", _, socket) do
    route_to_show = Routes.activity_index_path(socket, :index)

    {:noreply, push_patch(socket, to: route_to_show)}
  end

  defp list_activities do
    Activities.list_activities()
  end
end
