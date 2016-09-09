defmodule VKReq do
  @moduledoc """
  This plug ensures request is a valid VK request
  It validates GET parameters and executes either `on_success/1` or `on_error/2` function
  of the callback module specified in config.
  The plug only performs validation but not actual request processing (ex. user sign-in or sign-up).
  You can implement logic for valid/invalid VK requests in callback module's functions.

  All VK requests must have following GET params to be succesfully validated:
  * api_id      - registered VK application ID, ex. "1234567", should match app_id specified in config
  * viewer_id   - ID of VK user opening the app
  * auth_key    - hashed signature for the 3 "_"-separated params: "APPID_VIEWERID_APPSECRET"

  ## Configuration

      config :vkreq, VKReq,
        app_id: "1234567",
        app_key: "0123456789abcdefABCD",
        callback_module: MyApp.VKReqCallback

  Any of the config params can be passed as plug options, example:
      
      plug VKReq, app_id: "1234567", app_key: "0123456789abcdefABCD", callback_module: MyApp.VKReqCallback
  """

  import Plug.Conn
  @behaviour Plug

  @doc false
  def init(params) do
    config = Application.get_env(:vkreq, VKReq)
    |> Enum.into(%{})
    params = Enum.into(params, %{})
    Map.merge(config, params)
  end

  @doc false
  def call(conn, config) do
    conn = fetch_query_params(conn)
    case validate_request(conn.query_params, config.app_id, config.app_key) do
      :ok ->
        config.callback_module.on_success(conn)
      {:error, error} ->
        config.callback_module.on_error(conn, error)
    end
  end

  defp validate_request(%{"api_id" => app_id, "viewer_id" => viewer_id, "auth_key" => auth_key}, app_id, app_key) do
    hash = "#{app_id}_#{viewer_id}_#{app_key}"
    |> :erlang.md5()
    |> Base.encode16(case: :lower)
    case hash do
      ^auth_key -> :ok
      _invalid -> {:error, :hash_mismatch}
    end
  end
  defp validate_request(_params, _app_id, _app_key), do: {:error, :required_params_missing}
end
