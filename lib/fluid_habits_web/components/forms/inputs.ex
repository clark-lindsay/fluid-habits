defmodule FluidHabitsWeb.Components.Forms.Inputs do
  @doc """
  Generate timezone names suitable for use as options in an `<input type="select">` tag
  """
  def timezone_options() do
    Timex.timezones()
    |> Enum.map(fn zone ->
      %{full_name: full_name, abbreviation: abbreviation} =
        zone_info = Timex.timezone(zone, Timex.now())

      offset = Timex.TimezoneInfo.format_offset(zone_info)

      {"#{full_name} (#{abbreviation}) -- UTC#{offset}", zone}
    end)
  end
end
