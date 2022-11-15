defmodule FluidHabits.DateTime do
  def split_into_intervals(
        %DateTime{time_zone: time_zone} = period_start,
        %DateTime{time_zone: time_zone} = period_end,
        granularity \\ :weeks
      ) do
    end_of_interval =
      case granularity do
        :days -> &Timex.end_of_day/1
        :months -> &Timex.end_of_month/1
        :years -> &Timex.end_of_year/1
        _ -> &Timex.end_of_week(&1, :mon)
      end

    if Timex.after?(period_start, period_end) do
      []
    else
      Timex.Interval.new(
        from: DateTime.to_naive(period_start),
        until: DateTime.to_naive(period_end),
        right_open: false,
        step: [hours: 12]
      )
      |> Enum.group_by(end_of_interval)
      |> Enum.sort(fn {end_of_interval_a, _date_a}, {end_of_interval_b, _date_b} ->
        Timex.before?(end_of_interval_a, end_of_interval_b)
      end)
      |> Enum.map(fn {_, date_times} ->
        from =
          hd(date_times)
          |> Timex.to_datetime(period_start.time_zone)
          |> Timex.beginning_of_day()

        until = end_of_interval.(from)

        if !Timex.is_valid?(hd(date_times)) do
          raise "Invalid datetime of #{inspect(hd(date_times))} for timezone #{time_zone}"
        end

        until =
          if Timex.before?(period_end, until) do
            period_end
          else
            until
          end

        %{
          from: DateTime.shift_zone!(from, "Etc/UTC"),
          until: DateTime.shift_zone!(until, "Etc/UTC")
        }
      end)
    end
  end
end
