defmodule VKReq.Callback do
  @moduledoc """
  This is example callback module for VKReq plug
  """
  import Plug.Conn

  @doc """
  The function is being called when request is verified to be VK request
  One of possible use-cases for the function is user signin-or-signup
  """
  @spec on_success(Plug.Conn.t) :: Plug.Conn.t
  def on_success(conn) do
    conn
  end

  @doc """
  The function is being called when request is verified to be invalid VK request
  This can happen for 2 reasons and one of 2 `error` values will be given to the function:
  * :hash_mismatch - request's "auth_key" param (hash) is invalid
  * :required_params_missing - request doesn't have minimally required params to perform a validation
  One of possible use-cases for the function is user signin-or-signup
  """
  @spec on_error(Plug.Conn.t, :hash_mismatch | :required_params_missing) :: Plug.Conn.t
  def on_error(conn, error) do
    conn
    |> send_resp(403, "Error: #{error}")
    |> halt()
  end
end
