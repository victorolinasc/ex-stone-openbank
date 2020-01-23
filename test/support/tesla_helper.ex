defmodule ExStoneOpenbank.TeslaHelper do
  @moduledoc """
  Group of functions that helps in the utilization of Mox in Tesla Adapters
  """
  import Mox
  import Tesla.Mock, only: [json: 2]
  import ExUnit.Assertions
  alias ExStoneOpenbank.TeslaMock

  defmodule RequestMatchError do
    defexception [:message]

    def exception(request: request) do
      message = """

      A Tesla mock request could not be matched in an `expect_call`.

      This usually happens when the fun head can't match on an incoming request. Please,
      check if URL, method and other request data can match the expectation.

      Incoming request: #{inspect(request)}
      """

      %__MODULE__{message: message}
    end
  end

  @doc "Helper for expecting a Tesla call"
  @spec expect_call(n :: integer(), call_fun :: (Tesla.Env.t() -> {:ok | :error, Tesla.Env.t()})) ::
          term()
  def expect_call(n \\ 1, call_fun) do
    unless Function.info(call_fun, :arity) == {:arity, 1} do
      raise "expect_call must receive a function with arity 1"
    end

    TeslaMock
    |> expect(:call, n, fn request, _opts ->
      try do
        call_fun.(request)
      rescue
        FunctionClauseError ->
          reraise RequestMatchError, [request: request], __STACKTRACE__
      end
    end)
  end

  @doc "Helper for building a JSON Tesla.Env response"
  @spec json_response(body :: map() | String.t() | integer() | boolean(), status :: pos_integer()) ::
          {:ok, Tesla.Env.t()}
  def json_response(body, status \\ 200) do
    {:ok, json(body, status: status)}
  end

  @doc "Expects an authenticate call"
  @spec expect_authentication(client_id :: String.t(), {:ok, Tesla.Env.t()}) :: term()
  def expect_authentication(client_id, response \\ nil) do
    expect_call(1, fn
      %{headers: [{"content-type", "application/x-www-form-urlencoded"}]} = env ->
        assert_authentication(client_id, response, env)
    end)
  end

  def assert_authentication(client_id, response, env) do
    assert env.body =~ "client_id=#{client_id}"
    assert env.body =~ "grant_type=client_credentials"

    assert env.body =~
             "client_assertion_type=#{
               URI.encode_www_form("urn:ietf:params:oauth:client-assertion-type:jwt-bearer")
             }"

    if response,
      do: response,
      else: json_response(%{access_token: "token", refresh_token: "refresh_token"})
  end
end
