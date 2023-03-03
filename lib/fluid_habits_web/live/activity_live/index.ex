defmodule FluidHabitsWeb.ActivityLive.Index do
  use FluidHabitsWeb, :live_view

  alias FluidHabits.Activities
  alias FluidHabits.Activities.{Activity, ActivityQueries}
  alias FluidHabits.Repo

  @impl true
  def mount(_params, session, socket) do
    current_user = FluidHabits.Accounts.get_user_by_session_token(session["user_token"])

    start_of_current_week =
      Timex.now(current_user.timezone)
      |> Timex.beginning_of_week(:mon)

    activities =
      Activity
      |> ActivityQueries.for_user(current_user)
      |> Repo.all()
      |> Task.async_stream(fn activity ->
        weekly_score =
          Activities.scores_since(
            activity,
            DateTime.shift_zone!(start_of_current_week, "Etc/UTC"),
            limit: :infinity
          )
          |> Enum.reduce(0, fn {_date, score}, acc -> acc + score end)

        %{
          activity: activity,
          active_streak: Activities.active_streak(activity),
          streak_includes_today?: Activities.has_logged_achievement_today?(activity),
          weekly_score: weekly_score
        }
      end)
      |> Enum.map(fn {:ok, activity_data} -> activity_data end)

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
