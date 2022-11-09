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

    test "start and end must have the same time_zone" do
      now_eastern = Timex.now() |> DateTime.shift_zone!("US/Eastern")
      tomorrow_pacific = Timex.now() |> Timex.shift(days: 1) |> DateTime.shift_zone!("US/Pacific")

      assert_raise FunctionClauseError,
                   fn ->
                     FluidHabits.DateTime.split_into_intervals(now_eastern, tomorrow_pacific)
                   end
    end

    test "set of intervals covers exactly the time period from start to end" do
      # excluding "Etc" zones due to a weird issue where midnight in the Etc-01 timezone
      # and 23:00 the day before were not comparing as equal
      check all(
              start_year <- StreamData.integer(2020..2025),
              start_day <- StreamData.integer(1..365),
              end_year <- StreamData.integer(2020..2025),
              end_day <- StreamData.integer(1..365),
              time_zone <-
                StreamData.member_of(
                  Timex.timezones()
                  |> Enum.filter(fn tz -> !String.contains?(tz, "Etc") end)
                )
            ) do
        period_start =
          Timex.from_iso_day(start_day, start_year)
          |> Timex.to_datetime()
          |> DateTime.shift_zone!(time_zone)

        period_end =
          Timex.from_iso_day(end_day, end_year)
          |> Timex.to_datetime()
          |> DateTime.shift_zone!(time_zone)

        {period_start, period_end} =
          if Timex.before?(period_start, period_end) do
            {period_start, period_end}
          else
            {period_end, period_start}
          end

        {period_start, period_end} =
          {Timex.beginning_of_day(period_start), Timex.end_of_day(period_end)}

        intervals = FluidHabits.DateTime.split_into_intervals(period_start, period_end)

        assert Timex.equal?(period_start, hd(intervals)[:from])
        assert Timex.equal?(period_end, List.last(intervals)[:until])
      end
    end

    test "set of returned intervals is strictly ordered, and each interval is strictly ordered" do
      check all(
              start_year <- StreamData.integer(2020..2025),
              start_day <- StreamData.integer(1..365),
              end_year <- StreamData.integer(2020..2025),
              end_day <- StreamData.integer(1..365),
              time_zone <- StreamData.member_of(Timex.timezones())
            ) do
        period_start =
          Timex.from_iso_day(start_day, start_year)
          |> Timex.to_datetime(time_zone)
          |> Timex.beginning_of_day()

        period_end =
          Timex.from_iso_day(end_day, end_year)
          |> Timex.to_datetime(time_zone)
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
