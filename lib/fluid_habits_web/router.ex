defmodule FluidHabitsWeb.Router do
  use FluidHabitsWeb, :router

  import FluidHabitsWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {FluidHabitsWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  # if logged in, immediately redirect to a new "/home" page, which renders
  # a card for each activity and its
  # current "streak", with the last ~5 (?) achievements 
  scope "/", FluidHabitsWeb do
    pipe_through :browser

    get "/", PageController, :index
  end

  scope "/activities", FluidHabitsWeb do
    pipe_through [:browser, :require_authenticated_user]

    live "/", ActivityLive.Index, :index
    live "/new", ActivityLive.Index, :new
    live "/:id/edit", ActivityLive.Index, :edit

    live "/:id", ActivityLive.Show, :show
    live "/:id/show/edit", ActivityLive.Show, :edit
    live "/:id/show/add-ach-lvl", ActivityLive.Show, :add_ach_lvl
    live "/:id/show/add-achievement", ActivityLive.Show, :add_achievement
    live "/:id/show/add-ach-group", ActivityLive.Show, :add_ach_group
  end

  scope "/stats", FluidHabitsWeb do
    pipe_through [:browser, :require_authenticated_user]

    live "/", StatsLive.Index, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", FluidHabitsWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: FluidHabitsWeb.Telemetry
    end
  end

  # Enables the Swoosh mailbox preview in development.
  #
  # Note that preview only shows emails that were sent by the same
  # node running the Phoenix server.
  if Mix.env() == :dev do
    scope "/dev" do
      pipe_through :browser

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Live Authentication routes

  scope "/", FluidHabitsWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{FluidHabitsWeb.UserAuth, :redirect_if_user_is_authenticated}] do
      live "/users/register", UserRegistrationLive, :new
      live "/users/log_in", UserLoginLive, :new
      live "/users/reset_password", UserForgotPasswordLive, :new
      live "/users/reset_password/:token", UserResetPasswordLive, :edit
    end

    post "/users/log_in", UserSessionController, :create
  end

  scope "/", FluidHabitsWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{FluidHabitsWeb.UserAuth, :ensure_authenticated}] do
      live "/users/settings", UserSettingsLive, :edit
      live "/users/settings/confirm_email/:token", UserSettingsLive, :confirm_email
    end
  end

  scope "/", FluidHabitsWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete

    live_session :current_user,
      on_mount: [{FluidHabitsWeb.UserAuth, :mount_current_user}] do
      live "/users/confirm/:token", UserConfirmationLive, :edit
      live "/users/confirm", UserConfirmationInstructionsLive, :new
    end
  end

end
