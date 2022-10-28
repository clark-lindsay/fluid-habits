defmodule FluidHabitsWeb.UserSettingsView do
  use FluidHabitsWeb, :view

  defp timezone_options() do
    Timex.timezones()
    |> Enum.map(fn zone ->
      %{full_name: full_name, abbreviation: abbreviation} =
        zone_info = Timex.timezone(zone, Timex.now())

      offset = Timex.TimezoneInfo.format_offset(zone_info)

      {"#{full_name} (#{abbreviation}) -- UTC#{offset}", zone}
    end)
  end
end
