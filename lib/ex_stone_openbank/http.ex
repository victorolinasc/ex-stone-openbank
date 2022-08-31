defmodule ExStoneOpenbank.HTTP do
  @moduledoc false
  require Logger

  alias ExStoneOpenbank.Authenticator.AuthHTTPMiddleware
  alias ExStoneOpenbank.{Config, Page}
  alias Tesla.Middleware

  @hackney {Tesla.Adapter.Hackney, [recv_timeout: 10_000]}
  @adapter Application.get_env(:ex_stone_openbank, :adapter, @hackney)

  @typedoc """
  Possible error reasons in HTTP call
  """
  @type error_reason ::
          :bad_request
          | :unauthenticated
          | :unauthorized
          | :not_found
          | :unprocessable_entity
          | :client_error
          | :server_error
          | :unexpected_return

  @typep body ::
           %{required(String.t()) => body()}
           | list(body())
           | number()
           | boolean()
           | String.t()
           | map()
           | struct()
  @typep parsed_return :: {:ok, body} | {:error, error_reason}

  defguardp is_client_error(status) when is_integer(status) and status >= 400 and status < 500
  defguardp is_server_error(status) when is_integer(status) and status >= 500
  defguardp is_success(status) when is_integer(status) and status >= 200 and status < 300

  @doc """
  Client for the login call.
  """
  def login_client do
    Tesla.client([Middleware.FormUrlencoded, Middleware.DecodeJson, Middleware.Logger], @adapter)
  end

  @doc """
  Client for the API calls.
  """
  def api_client(config_name) do
    Tesla.client(
      [
        {Middleware.BaseUrl, Config.api_url(config_name) <> "/api/v1"},
        Middleware.JSON,
        Middleware.Logger,
        {Middleware.Headers,
         [{"user-agent", "service-application: #{Config.client_id(config_name)}"}]},
        {AuthHTTPMiddleware, %{config_name: config_name}}
      ],
      @adapter
    )
  end

  def get(config_name, path, http_opts \\ [], parse_opts \\ []) do
    config_name
    |> api_client()
    |> Tesla.get(path, http_opts)
    |> parse_result(parse_opts)
  end

  def post(config_name, path, body, http_opts \\ [], parse_opts \\ []) do
    config_name
    |> api_client()
    |> Tesla.post(path, body, http_opts)
    |> parse_result(parse_opts)
  end

  def put(config_name, path, body, http_opts \\ [], parse_opts \\ []) do
    config_name
    |> api_client()
    |> Tesla.put(path, body, http_opts)
    |> parse_result(parse_opts)
  end

  def patch(config_name, path, body, http_opts \\ [], parse_opts \\ []) do
    config_name
    |> api_client()
    |> Tesla.patch(path, body, http_opts)
    |> parse_result(parse_opts)
  end

  def delete(config_name, path, http_opts \\ [], parse_opts \\ []) do
    config_name
    |> api_client()
    |> Tesla.delete(path, http_opts)
    |> parse_result(parse_opts)
  end

  @doc """
  Parses the result returning either the body or the error reason atom.
  """
  @spec parse_result({:ok, tesla_env :: map()} | {:error, reason :: atom()}, Keyword.t()) ::
          parsed_return()
  def parse_result(result, opts \\ [])

  def parse_result({:ok, %{status: status} = env}, opts) when is_success(status) do
    body = parse_body(env.body, opts)

    if opts[:headers] do
      {:ok, body, env.headers}
    else
      {:ok, body}
    end
  end

  def parse_result({:ok, %{status: 400, body: body}}, _opts) do
    Logger.info("Bad request. Body: #{inspect(body)}")
    {:error, :bad_request}
  end

  def parse_result({:ok, %{status: 422, body: body}}, _opts) do
    Logger.info("Unprocessable entity. Body: #{inspect(body)}")
    {:error, :unprocessable_entity}
  end

  def parse_result({:ok, %{status: 401}}, _opts), do: {:error, :unauthenticated}
  def parse_result({:ok, %{status: 403}}, _opts), do: {:error, :unauthorized}
  def parse_result({:ok, %{status: 404}}, _opts), do: {:error, :not_found}

  def parse_result({:ok, %{status: status}}, _opts) when is_client_error(status),
    do: {:error, :client_error}

  def parse_result({:ok, %{status: status}}, _opts) when is_server_error(status),
    do: {:error, :server_error}

  def parse_result({:error, _reason} = err, _opts), do: err
  def parse_result(_, _), do: {:error, :unexpected_return}

  def parse_body(%{"cursor" => _cursor, "data" => data} = page, opts) when is_list(data) do
    page
    |> Page.cast_and_apply()
    |> Page.parse_data_model(opts[:model])
  end

  def parse_body(body, opts) do
    model = opts[:model]

    if model, do: model.cast_and_apply(body), else: body
  end
end
