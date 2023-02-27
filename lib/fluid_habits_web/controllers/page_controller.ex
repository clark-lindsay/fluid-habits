defmodule FluidHabitsWeb.PageController do
  use FluidHabitsWeb, :controller

  def index(conn, _params) do
    render(conn, :index)
  end
end
