defmodule FluidHabits.DateTime do
  def split_into_intervals(
        %DateTime{} = period_start,
        %DateTime{} = period_end,
        granularity \\ :weeks
      ) do
    if Timex.after?(period_start, period_end) do
      []
    else
      Timex.Interval.new(from: period_start, until: period_end, step: [days: 1])
      |> Enum.to_list()
      |> Enum.group_by(&Timex.iso_week/1)
      |> Enum.sort(:asc)
      |> Enum.map(fn {{_year, _week}, datetimes} ->
        from =
          hd(datetimes)
          |> Timex.to_datetime()
          |> Timex.beginning_of_day()

        until =
          if Timex.before?(period_end, Timex.end_of_week(from)) do
            period_end
          else
            Timex.end_of_week(from)
          end

        %{
          from: from,
          until: until
        }
      end)
    end
  end
end
