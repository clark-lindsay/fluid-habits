defmodule FluidHabitsWeb.ActivityLive.Index do
  use FluidHabitsWeb, :live_view

  alias FluidHabits.{Accounts, Activities}
  alias FluidHabits.Activities.{Activity, ActivityQueries}
  alias FluidHabits.Repo

  @impl true
  def mount(_params, session, socket) do
    current_user = FluidHabits.Accounts.get_user_by_session_token(session["user_token"])

    if connected?(socket) do
      Phoenix.PubSub.subscribe(FluidHabits.PubSub, "user:#{current_user.id}")
    end

    start_of_current_week = Accounts.start_of_week(current_user)

    activities =
      Activity
      |> ActivityQueries.for_user(current_user)
      |> Repo.all()
      |> Task.async_stream(fn activity ->
        %{
          activity: activity,
          active_streak: Activities.active_streak(activity),
          streak_includes_today?: Activities.has_logged_achievement_today?(activity),
          weekly_score: total_score_since(activity, start_of_current_week)
        }
      end)
      |> Enum.into(%{}, fn {:ok, %{activity: %{id: id}} = activity_data} ->
        {id, activity_data}
      end)

    {:ok,
     assign(socket,
       activities: activities,
       start_of_current_week: start_of_current_week,
       current_user: current_user
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
    |> assign(:activity, %Activity{})
  end

  @impl Phoenix.LiveView
  def handle_event("close_modal", _, socket) do
    route_to_show = ~p"/activities"

    {:noreply, push_patch(socket, to: route_to_show)}
  end

  @impl Phoenix.LiveView
  def handle_info({:create_achievement, %{achievement: %{activity: activity}}}, socket) do
    activity_data = %{
      activity: activity,
      active_streak: Activities.active_streak(activity),
      streak_includes_today?: Activities.has_logged_achievement_today?(activity),
      weekly_score: total_score_since(activity, socket.assigns.start_of_current_week)
    }

    socket =
      socket
      |> assign(activities: Map.put(socket.assigns.activities, activity.id, activity_data))

    {:noreply, socket}
  end

  defp total_score_since(activity, since) do
    Activities.scores_since(
      activity,
      DateTime.shift_zone!(since, "Etc/UTC"),
      limit: :infinity
    )
    |> Enum.reduce(0, fn {_date, score}, acc -> acc + score end)
  end
end
