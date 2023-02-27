defmodule FluidHabitsWeb.ActivityLive.Index do
  use FluidHabitsWeb, :live_view

  alias FluidHabits.Activities.Activity
  alias FluidHabits.Repo

  @impl true
  def mount(_params, session, socket) do
    # get user by session token, store in socket

    user = FluidHabits.Accounts.get_user_by_session_token(session["user_token"])

    {:ok,
     assign(socket,
       activities: Repo.all(Activity),
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
    |> assign(:activity, Repo.get!(Activity, id))
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
    activity = Repo.get!(Activity, id)
    {:ok, _} = Repo.delete(activity)

    {:noreply, assign(socket, :activities, Repo.all(Activity))}
  end

  @impl Phoenix.LiveView
  def handle_event("close_modal", _, socket) do
    route_to_show = ~p"/activities"

    {:noreply, push_patch(socket, to: route_to_show)}
  end
end
