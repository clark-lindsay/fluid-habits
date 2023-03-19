defmodule FluidHabitsWeb.StatsLive.Index do
  use FluidHabitsWeb, :live_view

  alias FluidHabits.Accounts
  alias FluidHabits.Accounts.User

  @impl Phoenix.LiveView
  def mount(params, %{"user_token" => user_token} = _session, socket) do
    current_user = Accounts.get_user_by_session_token(user_token)

    if(connected?(socket)) do
      Phoenix.PubSub.subscribe(FluidHabits.PubSub, "user:#{current_user.id}")
    end

    socket =
      socket
      |> assign(:current_user, current_user)

    import Ecto.Query, only: [from: 2]

    activities =
      from(act in FluidHabits.Activities.Activity,
        where: act.user_id == ^socket.assigns.current_user.id
      )
      |> FluidHabits.Repo.all()

    default_from =
      Timex.now(current_user.timezone)
      |> Timex.shift(months: -1)
      |> Timex.beginning_of_month()
      |> Timex.to_date()
      |> Date.to_iso8601()

    default_until =
      Timex.now(current_user.timezone)
      |> Timex.end_of_month()
      |> Timex.to_date()
      |> Date.to_iso8601()

    changeset =
      change_stats_params(%{}, %{
        from: params["from"] || default_from,
        until: params["until"] || default_until,
        granularity: params["granularity"] || "Weeks",
        activities: params["activities"]
      })

    socket =
      assign(socket,
        changeset: changeset,
        activities: activities,
        scored_intervals: %{}
      )

    {:ok, socket}
  end

  @impl Phoenix.LiveView
  def handle_params(
        %{
          "granularity" => granularity,
          "activities" => activity_ids,
          "from" => from,
          "until" => until
        },
        _uri,
        socket
      ) do
    from =
      Timex.parse!(
        from,
        "{YYYY}-{0M}-{D}"
      )
      |> Timex.to_datetime(socket.assigns.current_user.timezone)
      |> Timex.beginning_of_day()

    until =
      Timex.parse!(
        until,
        "{YYYY}-{0M}-{D}"
      )
      |> Timex.to_datetime(socket.assigns.current_user.timezone)
      |> Timex.end_of_day()

    activity_ids = if(is_list(activity_ids), do: activity_ids, else: [])

    intervals =
      FluidHabits.DateTime.split_into_intervals(
        from,
        until,
        to_granularity_atom(granularity)
      )

    scored_intervals = interval_scores(activity_ids, intervals)

    {:noreply, assign(socket, scored_intervals: scored_intervals)}
  end

  @impl Phoenix.LiveView
  def handle_params(%{}, _, socket), do: {:noreply, socket}

  @impl Phoenix.LiveView
  def handle_params(_, _, socket) do
    socket = Phoenix.LiveView.push_patch(socket, to: ~p"/stats")

    {:noreply, socket}
  end

  @impl Phoenix.LiveView
  def handle_event(
        "period_parameters_change",
        %{
          "stats_params" =>
            params = %{
              "granularity" => granularity,
              "activities" => activity_ids,
              "from" => from,
              "until" => until
            }
        },
        socket
      ) do
    changeset =
      socket.assigns.changeset
      |> change_stats_params(params)

    socket = assign(socket, changeset: changeset)

    if changeset.valid? do
      query_params = %{
        granularity: granularity,
        activities: activity_ids,
        from: from,
        until: until
      }

      socket =
        Phoenix.LiveView.push_patch(socket,
          to: ~p"/stats?#{query_params}"
        )

      {:noreply, socket}
    else
      {:error, changeset_with_action} =
        Ecto.Changeset.apply_action(socket.assigns.changeset, :insert)

      socket = assign(socket, changeset: changeset_with_action)

      {:noreply, socket}
    end
  end

  @impl Phoenix.LiveView
  def handle_info({:create_achievement, %{achievement: %{activity: %{user: user}}}}, socket) do
    if user.id == socket.assigns.current_user.id do
      # could find the correct interval, if it exists in the current set, and update the score
      # just going to take it easy for now and re-calculate all scores

      %{granularity: granularity, activities: activity_ids, from: from, until: until} =
        socket.assigns.changeset.changes

      {:ok, from_date} = Date.from_iso8601(from)
      {:ok, until_date} = Date.from_iso8601(until)

      intervals =
        FluidHabits.DateTime.split_into_intervals(
          Timex.to_datetime(from_date, user.timezone),
          Timex.to_datetime(until_date, user.timezone),
          to_granularity_atom(granularity)
        )

      scored_intervals = interval_scores(activity_ids, intervals)

      {:noreply, assign(socket, scored_intervals: scored_intervals)}
    else
      {:noreply, socket}
    end
  end

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <div class="flex flex-col gap-2">
      <.h2>Stats!</.h2>

      <.card class="p-2 w-full">
        <.card_content heading="Form">
          <.form
            :let={f}
            as={:stats_params}
            for={@changeset}
            id="stats-form"
            phx-change="period_parameters_change"
          >
            <div class="w-full py-2 flex flex-row gap-4 justify-between">
              <div class="flex flex-col justify-between">
                <.form_field type="date_input" form={f} field={:from} label="From" />
                <.form_field type="date_input" form={f} field={:until} label="Until" />

                <.form_field
                  type="select"
                  options={[
                    "Days",
                    "Weeks",
                    "Months",
                    "Years"
                  ]}
                  form={f}
                  field={:granularity}
                  label="Granularity"
                />
              </div>
              <.form_field
                type="checkbox_group"
                options={Enum.map(@activities, &{&1.name, &1.id})}
                form={f}
                field={:activities}
                label="Activities"
              />
            </div>
          </.form>
        </.card_content>
      </.card>

      <%= example_bar_chart(@scored_intervals) %>

      <ul>
        <%= for {_activity_id, interval: %{from: from, until: until}, score: score} <- @scored_intervals do %>
          <li>
            <%= to_user_timezone!(from, @current_user, output: :date) %> -> <%= to_user_timezone!(
              until,
              @current_user,
              output: :date
            ) %> : <%= score %>
          </li>
        <% end %>
      </ul>
    </div>
    """
  end

  defp interval_scores(_, []), do: []

  defp interval_scores(activity_ids, intervals) do
    activities = FluidHabits.Activities.list_activities_with_ids!(activity_ids)

    Task.Supervisor.async_stream(
      FluidHabits.TaskSupervisor,
      activities,
      fn activity ->
        scores_per_day =
          FluidHabits.Activities.scores_since(
            activity,
            hd(intervals)[:from],
            until: List.last(intervals)[:until]
          )

        # match each `interval` against `scores_per_day` to reduce the scores to
        # one total score per interval
        Stream.map(intervals, fn interval = %{from: from, until: until} ->
          scores_within_interval =
            Enum.filter(scores_per_day, fn {date, _score} ->
              date =
                Timex.to_datetime(date)
                |> Timex.set(hour: 12)

              Timex.before?(from, date) and Timex.after?(until, date)
            end)

          total_score_for_interval =
            Enum.reduce(scores_within_interval, 0, fn {_date, score}, acc -> acc + score end)

          %{
            interval: interval,
            score: total_score_for_interval,
            activity_id: activity.id
          }
        end)
      end,
      ordered: true
    )
    |> Stream.filter(fn task_result ->
      case task_result do
        {:ok, _result} ->
          true

        {_error, reason} ->
          IO.warn("Failed to score an activity with reason: #{inspect(reason)}")
          false
      end
    end)
    |> Stream.flat_map(fn {_tag, result} ->
      Enum.sort(result, fn %{interval: %{from: from_a}}, %{interval: %{from: from_b}} ->
        Timex.before?(from_a, from_b)
      end)
    end)
    |> Enum.to_list()
  end

  defp change_stats_params(data, params) do
    # using `:naive_datetime` because we will assume that a user will use the
    # inputs to select datetimes local to their timezone, and there is no `Ecto`
    # datetime type with a non-UTC timezone
    types = %{
      from: :string,
      until: :string,
      granularity: :string,
      activities: {:array, :id}
    }

    is_valid_iso_date? = fn field, date_str ->
      case Date.from_iso8601(date_str) do
        {:ok, _date} -> []
        _ -> [{field, "must be a valid date format"}]
      end
    end

    {data, types}
    |> Ecto.Changeset.cast(params, Map.keys(types))
    |> Ecto.Changeset.validate_required([:granularity, :from, :until])
    |> Ecto.Changeset.validate_change(:from, is_valid_iso_date?)
    |> Ecto.Changeset.validate_change(:until, is_valid_iso_date?)
  end

  @doc """
  Convert the granularity options presented in the HTML as strings into atoms
  to conform the value for the options of date-time manipulation functions

  Passes atoms through unchanged.

    ## Examples

    iex > to_granularity_atom("Days")
    # => :days
    iex > to_granularity_atom(:weeks)
    # => :weeks
  """
  @spec to_granularity_atom(String.t() | atom()) :: atom()
  defp to_granularity_atom(granularity) do
    if is_atom(granularity) do
      granularity
    else
      case String.downcase(granularity) do
        "days" -> :days
        "weeks" -> :weeks
        "months" -> :months
        "years" -> :years
      end
    end
  end

  defp to_user_timezone!(date_time, %User{timezone: timezone}, opts \\ []) do
    date_time =
      date_time
      |> DateTime.shift_zone!(timezone)

    case opts[:output] do
      :date -> DateTime.to_date(date_time)
      :time -> DateTime.to_time(date_time)
      _ -> date_time
    end
  end

  defp example_bar_chart(intervals) do
    # data = [
    #   %{"category" => "2023-03-17", "1" => 2, "2" => 4},
    #   %{"category" => "2023-03-18", "1" => 3, "2" => 1},
    # ]
    data =
      case intervals do
        arg when map_size(arg) == 0 ->
          [{"Needs data", 1}]

        _ ->
          intervals
          |> Enum.group_by(fn %{interval: %{from: from}} -> from end)
          |> Enum.map(fn {from, interval_data} ->

            interval_score_per_activity =
              Enum.reduce(interval_data, %{}, fn %{score: score, activity_id: activity_id}, acc ->
                Map.update(acc, "#{activity_id}", score, &(&1 + score))
              end)

            Map.merge(
              interval_score_per_activity,
              %{"category" => DateTime.to_date(from) |> Date.to_string()}
            )
          end)
      end

    chart =
      data
      |> Contex.Dataset.new()
      |> Contex.BarChart.new(
        type: :grouped,
        padding: 24,
        mapping: %{
          category_col: "category",
          value_cols:
            Enum.reduce(intervals, MapSet.new(), fn %{activity_id: activity_id}, acc ->
              MapSet.put(acc, "#{activity_id}")
            end)
            |> MapSet.to_list()
        }
      )

    Contex.Plot.new(600, 400, chart)
    |> Contex.Plot.to_svg()
  end
end
