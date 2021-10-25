defmodule ExStoneOpenbank.Authenticator do
  @moduledoc """
  Responsible for authentication of the service application.

  Authentication is done through issuing a JWT to the token endpoint according to client_credentials
  flow. The JWT is signed using the private key in the given configuration.

  The result is an access_token and a refresh_token. The access_token is used in all authenticated
  calls. The refresh token is used to get a new access_token without issuing a new token.
  """
  use GenServer

  alias ExStoneOpenbank.Authenticator.AuthenticationJWT
  alias ExStoneOpenbank.Config
  alias ExStoneOpenbank.HTTP

  require Logger

  # milliseconds to avoid re-fetching the token in case another process tried to request it before
  # the login finished
  @skew_time Application.get_env(:ex_stone_openbank, :time_skew, 2_000)

  def start_link(opts),
    do: GenServer.start_link(__MODULE__, opts, name: Keyword.fetch!(opts, :name))

  @impl true
  def init(opts) do
    opts = Config.validate_and_persist(opts)

    :ets.new(opts.name, [:named_table, read_concurrency: true])

    {:ok, opts, {:continue, :authenticate}}
  end

  @impl true
  def handle_continue(:authenticate, %{name: name} = state) do
    {:ok, _tokens} = authenticate(name)
    {:noreply, Map.put(state, :last_timestamp, new_timestamp())}
  end

  @impl true
  def handle_call(
        {:refresh_token, timestamp},
        _from,
        %{last_timestamp: last_timestamp, name: name} = state
      )
      when last_timestamp + @skew_time > timestamp do
    {:reply, tokens(name), state}
  end

  def handle_call(
        {:refresh_token, timestamp},
        _from,
        %{
          name: name,
          last_timestamp: last_timestamp
        } = state
      )
      when is_nil(last_timestamp) or last_timestamp + @skew_time <= timestamp do
    case authenticate(name) do
      {:ok, tokens} ->
        state = %{state | last_timestamp: new_timestamp()}
        {:reply, tokens, state}

      err ->
        {:reply, err, state}
    end
  end

  def handle_call(:last_timestamp, _, %{last_timestamp: ts} = state) do
    {:reply, ts, state}
  end

  @impl true
  def handle_info(_msg, state), do: {:noreply, state}

  @doc false
  def tokens(name), do: :ets.lookup(name, :tokens)[:tokens]

  defp last_timestamp(name), do: GenServer.call(name, :last_timestamp)

  defp new_timestamp, do: :erlang.system_time(:millisecond)

  @doc false
  def time_until_next_refresh(config_name) do
    ts = last_timestamp(config_name) + time_skew()
    now = new_timestamp()

    if now <= ts, do: ts - now, else: 0
  end

  @doc """
  Gets the access_token for the given configuration.
  """
  @spec access_token(name :: atom()) :: {:ok, String.t()} | {:error, :unauthenticated}
  def access_token(name) do
    case :ets.lookup(name, :tokens) do
      [tokens: tokens] -> {:ok, tokens[:access_token]}
      _ -> {:error, :unauthenticated}
    end
  end

  @doc """
  Refreshes the token synchronously
  """
  @spec refresh_token(name :: atom()) :: {:ok, String.t()}
  def refresh_token(name) do
    GenServer.call(name, {:refresh_token, new_timestamp()})
  end

  @doc """
  Authenticates with Stone Openbank API using the given signer and client_id
  """
  @spec authenticate(name :: atom()) ::
          {:ok, %{access_token: token :: String.t()}}
          | {:error, reason :: atom()}
  def authenticate(name) do
    with opts <- Config.options(name),
         {:ok, token, _claims} <- generate_client_credentials_token(name, opts),
         {:ok, %{"access_token" => access}} <- do_login(name, opts, token) do
      tokens = %{access_token: access}
      :ets.insert(name, {:tokens, tokens})
      {:ok, tokens}
    else
      error ->
        Logger.error("authenticate fail=#{inspect(error)}")
        raise "failed to authenticate"
    end
  end

  defp generate_client_credentials_token(name, opts) do
    AuthenticationJWT.generate_and_sign(
      %{
        "clientId" => opts.client_id,
        "sub" => opts.client_id,
        "iss" => opts.client_id,
        "aud" => Config.accounts_url(name) <> "/auth/realms/stone_bank"
      },
      opts.signer
    )
  end

  defp do_login(name, opts, token) do
    HTTP.login_client()
    |> Tesla.post(
      "#{Config.accounts_url(name)}/auth/realms/stone_bank/protocol/openid-connect/token",
      %{
        "grant_type" => "client_credentials",
        "client_id" => opts.client_id,
        "client_assertion_type" => "urn:ietf:params:oauth:client-assertion-type:jwt-bearer",
        "client_assertion" => token
      }
    )
    |> HTTP.parse_result()
  end

  @doc false
  def time_skew, do: @skew_time
end
