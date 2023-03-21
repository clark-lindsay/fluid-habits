defmodule FluidHabits.DataViz.BarChart do
  alias Contex.{BarChart, Plot}

  @doc """
  Takes in a `Contex.DataSet` and the `:mapping` option for a `Contex.BarChart` 
  to generate a themed bar chart which groups data from each value column together
  by their category to facilitate easy comparisons
  """
  def new(dataset, mapping) do
    chart =
      BarChart.new(dataset,
        type: :grouped,
        padding: 24,
        mapping: mapping,
        colour_palette: ["a855f7", "fde047", "06b6d4"]
      )

    Plot.new(600, 400, chart)
    |> Plot.to_svg()
  end
end
