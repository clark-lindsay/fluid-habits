defmodule FluidHabitsWeb.PageControllerTest do
  use FluidHabitsWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "Welcome to Fluid Habits!"
  end
end
