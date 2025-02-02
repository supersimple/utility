defmodule UtilityWeb.Nav do
  import Phoenix.LiveView

  def on_mount(:default, _params, _session, socket) do
    {:cont, attach_hook(socket, :active_tab, :handle_params, &set_active_tab/3)}
  end

  defp set_active_tab(_params, _url, socket) do
    active_tab =
      case {socket.view, socket.assigns.live_action} do
        {UtilityWeb.RegexLive, _} -> :regex
        {UtilityWeb.GenDiffLive, _} -> :gendiff
        {UtilityWeb.SinkLive, _} -> :sink
        {_, _} -> nil
      end

    {:cont, assign(socket, active_tab: active_tab)}
  end
end
