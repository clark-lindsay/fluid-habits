defmodule FluidHabitsWeb.StatsLive.Stats do
  use FluidHabitsWeb, :live_view

  alias FluidHabits.Accounts

  @impl Phoenix.LiveView
  def mount(_params, %{"user_token" => user_token} = _session, socket) do
    current_user = Accounts.get_user_by_session_token(user_token)

    socket =
      socket
      |> assign(:current_user, current_user)
      |> assign(
        :period_start,
        Timex.now(current_user.timezone) |> Timex.shift(months: -1) |> Timex.beginning_of_month()
      )
      |> assign(:period_end, Timex.now(current_user.timezone) |> Timex.end_of_month())

    socket =
      assign(
        socket,
        :intervals,
        FluidHabits.DateTime.split_into_intervals(
          socket.assigns.period_start,
          socket.assigns.period_end
        )
      )

    {:ok, socket}
  end

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <.h2>Stats!</.h2>

    <.card class="p-2">
      <.h3>Form</.h3>
      <div class="w-full py-2 flex flex-direction-row justify-between">
        <div>Start: <%= DateTime.to_date(@period_start) %></div>
        <div>End: <%= DateTime.to_date(@period_end) %></div>
      </div>
      <div class="w-full py-2 flex flex-direction-row justify-between">
        <div>Granularity: Weeks</div>
        <div>Activities: [...]</div>
      </div>
    </.card>

    <ul>
      <%= for interval <- @intervals do %>
        <li><%= interval.from %> -> <%= interval.until %></li>
      <% end %>
    </ul>
    """
  end
end
