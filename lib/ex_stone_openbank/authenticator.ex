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

  # milliseconds to avoid re-fetching the token in case another process tried to request it before
  # the login finished
  @skew_time 2_000

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
    tokens = authenticate(name)
    :ets.insert(name, {:tokens, tokens})

    {:noreply, Map.put(state, :last_timestamp, :erlang.system_time())}
  end

  @impl true
  def handle_call(
        {:refresh_token, timestamp},
        _from,
        %{last_timestamp: last_timestamp, name: name} = state
      )
      when last_timestamp + @skew_time > timestamp do
    [tokens: tokens] = :ets.lookup(name, :tokens)
    {:reply, tokens, state}
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
    with {:ok, tokens} <- authenticate(name) do
      :ets.insert(name, {:tokens, tokens})
      {:reply, tokens[:access_token], %{state | last_timestamp: :erlang.system_time()}}
    else
      err -> {:reply, err, state}
    end
  end

  @impl true
  def handle_info(_msg, state), do: {:noreply, state}

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
    GenServer.call(name, {:refresh_token, :erlang.system_time()})
  end

  @doc """
  Authenticates with Stone Openbank API using the given signer and client_id
  """
  @spec authenticate(name :: atom()) ::
          {:ok, %{access_token: token :: String.t(), refresh_token: token :: String.t()}}
          | {:error, reason :: atom()}
  def authenticate(name) do
    with opts <- Config.options(name),
         {:ok, token, _claims} <-
           AuthenticationJWT.generate_and_sign(
             %{
               "clientId" => opts.client_id,
               "sub" => opts.client_id,
               "aud" => Config.accounts_url(name) <> "/auth/realms/stone_bank"
             },
             opts.signer
           ),
         {:ok, %{"access_token" => access, "refresh_token" => refresh}} <-
           HTTP.login_client()
           |> Tesla.post(
             "#{Config.accounts_url(name)}/auth/realms/stone_bank/protocol/openid-connect/token",
             %{
               "grant_type" => "client_credentials",
               "client_id" => opts.client_id,
               "client_assertion_type" =>
                 "urn:ietf:params:oauth:client-assertion-type:jwt-bearer",
               "client_assertion" => token
             }
           )
           |> HTTP.parse_result() do
      %{access_token: access, refresh_token: refresh}
    end
  end
end
