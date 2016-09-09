# VKReq

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

## Installation

Add `vkreq` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:vkreq, "~> 0.1.0"}]
    end
    ```
