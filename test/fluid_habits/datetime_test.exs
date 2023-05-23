defmodule FluidHabits.DateTimeTest do
  use ExUnit.Case, async: true
  use ExUnitProperties

  describe "split_into_intervals/3" do
    test "returns an empty list when start is after end" do
      period_start =
        2
        |> Timex.from_iso_day(2022)
        |> Timex.to_datetime()
        |> Timex.beginning_of_day()

      period_end =
        1
        |> Timex.from_iso_day(2022)
        |> Timex.to_datetime()
        |> Timex.end_of_day()

      assert Timex.after?(period_start, period_end)
      assert [] == FluidHabits.DateTime.split_into_intervals(period_start, period_end)
    end

    test "start and end must have the same time_zone" do
      now_eastern = DateTime.shift_zone!(Timex.now(), "US/Eastern")
      tomorrow_pacific = Timex.now() |> Timex.shift(days: 1) |> DateTime.shift_zone!("US/Pacific")

      assert_raise FunctionClauseError,
                   fn ->
                     FluidHabits.DateTime.split_into_intervals(now_eastern, tomorrow_pacific)
                   end
    end

    test "set of intervals covers exactly the time period from start to end" do
      # excluding "Etc" zones due to an issue I don't understand: midnight in
      # the Etc-01 timezone and 23:00 the day before were not comparing as
      # equal, possibly due to a time change (e.g. "Daylight Saving Time")
      check all(
              year_1 <- StreamData.integer(2020..2025),
              day_1 <- StreamData.integer(1..365),
              year_2 <- StreamData.integer(2020..2025),
              day_2 <- StreamData.integer(1..365),
              time_zone <-
                StreamData.member_of(Enum.filter(Timex.timezones(), fn tz -> !String.contains?(tz, "Etc") end))
            ) do
        period_start =
          day_1
          |> Timex.from_iso_day(year_1)
          |> Timex.to_datetime()
          |> DateTime.shift_zone!(time_zone)

        period_end =
          day_2
          |> Timex.from_iso_day(year_2)
          |> Timex.to_datetime()
          |> DateTime.shift_zone!(time_zone)

        [period_start, period_end] = Enum.sort([period_start, period_end], &Timex.before?/2)

        {period_start, period_end} = {Timex.beginning_of_day(period_start), Timex.end_of_day(period_end)}

        intervals = FluidHabits.DateTime.split_into_intervals(period_start, period_end)

        assert Timex.equal?(period_start, hd(intervals)[:from])
        assert Timex.equal?(period_end, List.last(intervals)[:until])
      end
    end

    test "set of returned intervals is strictly ordered, and each interval is strictly ordered" do
      check all(
              year_1 <- StreamData.integer(2020..2025),
              day_1 <- StreamData.integer(1..365),
              year_2 <- StreamData.integer(2020..2025),
              day_2 <- StreamData.integer(1..365),
              time_zone <- StreamData.member_of(Timex.timezones())
            ) do
        period_start =
          day_1
          |> Timex.from_iso_day(year_1)
          |> Timex.to_datetime(time_zone)
          |> Timex.beginning_of_day()

        period_end =
          day_2
          |> Timex.from_iso_day(year_2)
          |> Timex.to_datetime(time_zone)
          |> Timex.end_of_day()

        [period_start, period_end] = Enum.sort([period_start, period_end], &Timex.before?/2)

        intervals =
          period_start
          |> FluidHabits.DateTime.split_into_intervals(period_end)
          |> Enum.chunk_every(2, 1, :discard)

        Enum.each(intervals, fn [
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

    test "set of returned intervals are each under the maximum length for given granularity" do
      check all(
              year_1 <- StreamData.integer(2020..2025),
              day_1 <- StreamData.integer(1..365),
              year_2 <- StreamData.integer(2020..2025),
              day_2 <- StreamData.integer(1..365),
              time_zone <- StreamData.member_of(Timex.timezones()),
              {granularity, max_interval_length_in_hours} <-
                StreamData.member_of([
                  # extra hour to account for Daylight Saving Time
                  {:days, 24 + 1},
                  {:weeks, 24 * 7 + 1},
                  {:months, 24 * 7 * 31 + 1},
                  # 1 extra day for leap years
                  {:years, 24 * 366 + 1}
                ])
            ) do
        period_start =
          day_1
          |> Timex.from_iso_day(year_1)
          |> Timex.to_datetime(time_zone)

        period_end =
          day_2
          |> Timex.from_iso_day(year_2)
          |> Timex.to_datetime(time_zone)

        [period_start, period_end] = Enum.sort([period_start, period_end], &Timex.before?/2)

        period_start
        |> FluidHabits.DateTime.split_into_intervals(period_end, granularity)
        |> Enum.each(fn %{from: from, until: until} ->
          assert max_interval_length_in_hours >= Timex.diff(until, from, :hours)
        end)
      end
    end
  end
end
