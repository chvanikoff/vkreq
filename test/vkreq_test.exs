defmodule VKReqTest do
  use ExUnit.Case, async: true
  use Plug.Test

  @viewer_id  "42"

  defmodule TestRouterPlug do
    import Plug.Conn
    use Plug.Router

    plug :match
    plug VKReq, callback_module: VKReqTest.Callback
    plug :dispatch

    get "/" do
      send_resp(conn, 200, "OK")
    end
  end

  defmodule TestRouterPlugDisabled do
    import Plug.Conn
    use Plug.Router

    plug :match
    plug VKReq, callback_module: VKReqTest.Callback, enabled: false
    plug :dispatch

    get "/" do
      send_resp(conn, 200, "OK")
    end
  end

  defmodule Callback do
    import Plug.Conn

    def on_success(conn) do
      conn
      |> put_private(:test_callback, "ran")
    end

    def on_error(conn, error) do
      conn
      |> send_resp(403, "Error: #{error}")
      |> halt()
    end
  end

  setup do
    config = Application.get_env(:vkreq, VKReq)
    |> Enum.into(%{})
    {:ok, config: config}
  end

  test "Request will fail when no required VK params sent" do
    conn = conn(:get, "/")
    |> TestRouterPlug.call([])
    assert conn.status == 403
    assert conn.resp_body == "Error: required_params_missing"
  end

  test "Request will fail when hash is invalid", %{config: config} do
    invalid_auth_key = get_auth_key(config)
    |> String.reverse()
    conn = conn(:get, "/?api_id=#{config.app_id}&viewer_id=#{@viewer_id}&auth_key=#{invalid_auth_key}")
    |> TestRouterPlug.call([])
    assert conn.status == 403
    assert conn.resp_body == "Error: hash_mismatch"
  end

  test "Request will be normally processed when required params are in place and hash matches", %{config: config} do
    auth_key = get_auth_key(config)
    conn = conn(:get, "/?api_id=#{config.app_id}&viewer_id=#{@viewer_id}&auth_key=#{auth_key}")
    |> TestRouterPlug.call([])
    assert conn.status == 200
    assert conn.resp_body == "OK"
  end

  test "on_success callback is properly called", %{config: config} do
    auth_key = get_auth_key(config)
    conn = conn(:get, "/?api_id=#{config.app_id}&viewer_id=#{@viewer_id}&auth_key=#{auth_key}")
    |> TestRouterPlug.call([])
    assert conn.status == 200
    assert Map.has_key?(conn.private, :test_callback)
    assert conn.private.test_callback == "ran"
  end

  test "on_success callback is always called when 'enabled' config value is set to false", %{config: config} do
    conn = conn(:get, "/")
    |> TestRouterPlugDisabled.call([])
    assert conn.status == 200
    assert Map.has_key?(conn.private, :test_callback)
    assert conn.private.test_callback == "ran"
  end

  defp get_auth_key(config) do
    "#{config.app_id}_#{@viewer_id}_#{config.app_key}"
    |> :erlang.md5()
    |> Base.encode16(case: :lower)
  end
end

