defmodule UtilityWeb.PageController do
  use UtilityWeb, :controller

  def show(conn, _params) do
    redirect(conn, to: Routes.regex_path(conn, :new))
  end

  def healthcheck(conn, _params), do: conn |> send_resp(200, "ok") |> halt()

  def site_manifest(conn, _params) do
    json(conn, %{
      name: "Developer Utilities",
      short_name: "Utilities",
      icons: [
        %{
          src: Routes.static_path(conn, "/images/android-chrome-192x192.png"),
          sizes: "192x192",
          type: "image/png"
        },
        %{
          src: Routes.static_path(conn, "/images/android-chrome-512x512.png"),
          sizes: "512x512",
          type: "image/png"
        }
      ],
      theme_color: "#ffffff",
      background_color: "#ffffff"
    })
  end

  def browserconfig(conn, _params) do
    conn
    |> Plug.Conn.put_resp_content_type("application/xml")
    |> render("browserconfig.xml")
  end
end
