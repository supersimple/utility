defmodule UtilityWeb.Router do
  use UtilityWeb, :router
  import Phoenix.LiveDashboard.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :put_root_layout, {UtilityWeb.LayoutView, :root}
  end

  pipeline :crawlers do
    plug :accepts, ["xml", "json", "webmanifest"]
  end

  pipeline :sink_api do
    plug :accepts, ["json"]
  end

  pipeline :auth do
    plug :check_auth
  end

  scope "/", UtilityWeb do
    pipe_through [:browser]

    get "/", PageController, :show

    live_session :default, on_mount: UtilityWeb.Nav do
      live "/about", PageLive, :about
      live "/regex", RegexLive, :new
      live "/regex/:id", RegexLive, :show
      live "/sink", SinkLive, :new
      live "/sink/view/:id", SinkLive, :show
      live "/gendiff", GenDiffLive, :new
    end

    get "/gendiff/:project/:id", GenDiffController, :show
  end

  scope "/", UtilityWeb do
    pipe_through [:sink_api]

    match :*, "/sink/:foo_sink_id", SinkController, :any
  end

  scope "/", UtilityWeb, log: false do
    pipe_through [:crawlers]

    get "/site.webmanifest", PageController, :site_manifest
    get "/browserconfig.xml", PageController, :browserconfig
    get "/healthcheck", PageController, :healthcheck
  end

  scope "/admin" do
    pipe_through [:browser, :auth]
    live_dashboard "/dashboard", metrics: UtilityWeb.Telemetry
  end

  def check_auth(conn, _opts) do
    with {user, pass} <- Plug.BasicAuth.parse_basic_auth(conn),
         true <- user == System.get_env("AUTH_USER", "admin"),
         true <- pass == System.get_env("AUTH_PASS", "admin") do
      conn
    else
      _ ->
        conn
        |> Plug.BasicAuth.request_basic_auth()
        |> halt()
    end
  end
end
