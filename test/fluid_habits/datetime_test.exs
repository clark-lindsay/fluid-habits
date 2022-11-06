defmodule FluidHabits.DateTimeTest do
  use ExUnit.Case, async: true
  use ExUnitProperties

  describe "split_into_intervals/3" do
    test "returns an empty list when start is after end" do
      period_start =
        Timex.from_iso_day(2, 2022)
        |> Timex.to_datetime()
        |> Timex.beginning_of_day()

      period_end =
        Timex.from_iso_day(1, 2022)
        |> Timex.to_datetime()
        |> Timex.end_of_day()

      assert Timex.after?(period_start, period_end)
      assert [] == FluidHabits.DateTime.split_into_intervals(period_start, period_end)
    end

    test "set of returned intervals is strictly ordered, and each interval is strictly ordered" do
      check all(
              start_year <- StreamData.integer(2020..2025),
              start_day <- StreamData.integer(1..365),
              end_year <- StreamData.integer(2020..2025),
              end_day <- StreamData.integer(1..365)
            ) do
        period_start =
          Timex.from_iso_day(start_day, start_year)
          |> Timex.to_datetime()
          |> Timex.beginning_of_day()

        period_end =
          Timex.from_iso_day(end_day, end_year)
          |> Timex.to_datetime()
          |> Timex.end_of_day()

        {period_start, period_end} =
          if Timex.before?(period_start, period_end) do
            {period_start, period_end}
          else
            {period_end, period_start}
          end

        intervals =
          FluidHabits.DateTime.split_into_intervals(period_start, period_end)
          |> Enum.chunk_every(2, 1, :discard)

        Enum.map(intervals, fn [
                                 %{from: from, until: until},
                                 %{from: next_from}
                               ] ->
          # each interval is sorted
          assert Timex.before?(from, until)

          # the intervals are sorted, oldest first
          assert Timex.before?(from, next_from)
          assert Timex.before?(until, next_from)
        end)
      end
    end
  end
end
