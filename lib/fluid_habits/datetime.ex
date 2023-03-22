defmodule FluidHabits.DateTime do
  @moduledoc """
  Transformations and conversions for the basic `DateTime.t()` type that are
  unique requirements of this application.

  It is preferred to never `alias` this module, as it causes a name collision
  with the basic `DateTime` module
  """

  @doc """
  Return a chronologically ascending (newest first) list of maps, sorted by
  their `from` key, using UTC DateTimes to represent intervals whose size is
  _at most_ the maximum length of the given granularity, accounting for
  fluctuations in local time such as "Daylight Saving Time".

  _Excluding_ fluctuations, this results in maximum intervals per `granularity`
  as follows:
    - `:days`   -> 24 hours
    - `:weeks`  -> 7 days
    - `:months` -> 31 days
    - `:years`  -> 365 days

  The resulting intervals will each have a `:from` key representing the start
  of the interval in local time with microsecond precision, and an `:until`
  key representing the end of the interval in local time, running up to the
  last microsecond of the relevant date.

  Requires that the `period_start` and `period_end` arguments have the same
  `time_zone`

  Raises an exception in the event that a datetime is generated that _does not
  exist_ in the local timezone of the input arguments.
  """
  @spec split_into_intervals(DateTime.t(), DateTime.t(), :days | :weeks | :months | :years) ::
          [%{from: DateTime.t(), until: DateTime.t()}]
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

    # this may seem redundant, but it seems to handle edge cases generated by property-based testing
    # with a very wide variety of inputs and time zones
    if !Timex.before?(period_start, period_end) || Timex.after?(period_start, period_end) do
      []
    else
      Timex.Interval.new(
        from: DateTime.to_naive(period_start),
        until: DateTime.to_naive(period_end),
        right_open: false,
        step: [days: 1]
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

  @doc """
  Convert string granularity options, like those presented in HTML, into atoms
  to conform the data to the spec for the options of date-time manipulation functions

  Passes atoms through unchanged.

    ## Examples

    iex > to_granularity_atom("Days")
    # => :days
    iex > to_granularity_atom("months")
    # => :months
    iex > to_granularity_atom(:weeks)
    # => :weeks
  """
  @spec to_granularity_atom(String.t() | atom()) :: atom()
  def to_granularity_atom(granularity) do
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
end
