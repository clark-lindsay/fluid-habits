defmodule FluidHabits.DateTime do
  def split_into_intervals(
        %DateTime{time_zone: time_zone} = period_start,
        %DateTime{time_zone: time_zone} = period_end,
        granularity \\ :weeks
      ) do
    if Timex.after?(period_start, period_end) do
      []
    else
      Timex.Interval.new(
        from: DateTime.to_naive(period_start),
        until: DateTime.to_naive(period_end),
        right_open: false,
        step: [days: 1]
      )
      |> Enum.group_by(&Timex.end_of_week(&1, :mon))
      |> Enum.sort(fn {end_of_week_a, _date_a}, {end_of_week_b, _date_b} ->
        Timex.before?(end_of_week_a, end_of_week_b)
      end)
      |> Enum.map(fn {_end_of_week, date_times} ->
        from =
          hd(date_times)
          |> Timex.to_datetime(period_start.time_zone)
          |> Timex.beginning_of_day()

        end_of_week = Timex.end_of_week(from, :mon)

        until =
          if Timex.before?(period_end, end_of_week) do
            period_end
          else
            end_of_week
          end

        %{
          from: DateTime.shift_zone!(from, "Etc/UTC"),
          until: DateTime.shift_zone!(until, "Etc/UTC")
        }
      end)
    end
  end
end
