defmodule ExStoneOpenbank.Config do
  @moduledoc """
  Configuration options for ExStoneOpenbank
  """

  alias ExStoneOpenbank.URLProvider

  @doc """
  Validates given configuration and persists it during boot.
  """
  @spec validate_and_persist(opts :: Keyword.t()) :: %{
          name: atom(),
          client_id: String.t(),
          signer: Joken.Signer.t(),
          sandbox?: boolean()
        }
  def validate_and_persist(opts) do
    config =
      opts
      |> Keyword.put_new(:sandbox?, false)
      |> Enum.map(fn {key, value} -> validate(key, value) end)
      |> Map.new()
      |> build_url_provider()

    :persistent_term.put({__MODULE__, config.name}, config)

    config
  end

  defp build_url_provider(config) when is_map_key(config, :url_provider),
    do: config

  defp build_url_provider(%{sandbox?: sandbox?} = config) do
    environment = if sandbox?, do: :sandbox, else: :production

    Map.put(config, :url_provider, URLProvider.build(environment))
  end

  defp validate(:name, name) when is_atom(name) and not is_nil(name) and not is_boolean(name),
    do: {:name, name}

  defp validate(:name, _), do: raise("Name must be an atom")

  defp validate(:client_id, client_id) when is_binary(client_id), do: {:client_id, client_id}
  defp validate(:client_id, _), do: raise("Client ID is mandatory and must be a string")

  defp validate(:sandbox?, nil), do: {:sandbox?, false}
  defp validate(:sandbox?, value) when is_boolean(value), do: {:sandbox?, value}
  defp validate(:sandbox?, _), do: raise("`:sandbox?` must be a boolean or nil")

  defp validate(:url_provider, %URLProvider{} = url_provider), do: {:url_provider, url_provider}
  defp validate(:url_provider, _), do: raise("`:url_provider` must be an #{inspect(URLProvider)}")

  defp validate(:private_key, private_key) when not is_binary(private_key),
    do: raise("Private key must be a String with a PEM encoded RSA private key")

  # we change the key name here
  defp validate(:private_key, private_key) do
    {:signer, Joken.Signer.create("RS256", %{"pem" => private_key})}
  end

  defp validate(:consent_redirect_url, nil), do: {:consent_redirect_url, nil}

  defp validate(:consent_redirect_url, value) when is_binary(value) do
    case URI.parse(value) do
      %URI{scheme: scheme, host: host} = uri when not is_nil(scheme) and not is_nil(host) ->
        {:consent_redirect_url, uri}

      _ ->
        raise("Invalid consent_redirect_url")
    end
  end

  defp validate(:consent_redirect_url, _), do: raise("Invalid argument for consent_redirect_url")

  @doc """
  The Accounts URL for the given configuration name.

  It's either:
    - https://sandbox-accounts.openbank.stone.com.br
    - https://accounts.openbank.stone.com.br

  depending if its a sandbox application or production.
  or a custom value if your opts has a `:url_provider`
  with a valid #{inspect(URLProvider)}
  """
  @spec accounts_url(config_name :: atom()) :: String.t()
  def accounts_url(name) when is_atom(name),
    do: fetch_url(name, :accounts_url)

  @doc """
  The Conta URL for the given configuration name.

  It's either:
    - https://sandbox.conta.stone.com.br
    - https://conta.stone.com.br

  depending if its a sandbox application or production.
  or a custom value if your opts has a `:url_provider`
  with a valid #{inspect(URLProvider)}
  """
  @spec conta_url(config_name :: atom()) :: String.t()
  def conta_url(name) when is_atom(name),
    do: fetch_url(name, :conta_url)

  @doc """
  The API URL for the given configuration name.

  It's either:
    - https://sandbox-api.openbank.stone.com.br
    - https://api.openbank.stone.com.br

  depending if its a sandbox application or production
  or a custom value if your opts has a `:url_provider`
  with a valid #{inspect(URLProvider)}
  """
  @spec api_url(config_name :: atom()) :: String.t()
  def api_url(name) when is_atom(name),
    do: fetch_url(name, :api_url)

  @doc """
  The client_id for the given configuration name.
  """
  @spec client_id(config_name :: atom()) :: String.t()
  def client_id(name), do: options(name)[:client_id]

  @doc """
  Check whether is sandbox environment for the given configuration name.
  """
  @spec sandbox?(config_name :: atom()) :: String.t()
  def sandbox?(name), do: options(name)[:sandbox?]

  @doc """
  The `Joken.Signer.t` built from the private key of the given configuration name.
  """
  @spec signer(config_name :: atom()) :: Joken.Signer.t()
  def signer(name), do: options(name)[:signer]

  @doc """
  The consent_redirect_url for the given configuration name.
  """
  @spec consent_redirect_url(config_name :: atom()) :: String.t()
  def consent_redirect_url(name), do: options(name)[:consent_redirect_url]

  @doc """
  All options for the given configuration name.
  """
  @spec options(config_name :: atom()) :: Map.t()
  def options(name), do: :persistent_term.get({__MODULE__, name})

  defp fetch_url(name, url) do
    name
    |> options()
    |> Map.fetch!(:url_provider)
    |> Map.fetch!(url)
  end
end
