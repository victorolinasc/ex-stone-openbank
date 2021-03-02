defmodule ExStoneOpenbank.Consents do
  @moduledoc """
  Consent is the way to request access to a resource in Stone Open Bank API.
  """

  alias ExStoneOpenbank.Config

  defmodule Token do
    @moduledoc """
    Token configuration for the consent link.
    """
    use Joken.Config
    alias ExStoneOpenbank.Config

    @impl true
    def token_config do
      [skip: [:iss], aud: "accounts-hubid@openbank.stone.com.br"]
      |> default_claims()
      |> add_claim("type", fn -> "consent" end)
    end

    @doc "Convenience function for generating a token for a config name"
    def generate(config_name, opts \\ []) do
      client_id = Config.client_id(config_name)
      client_session = opts[:client_session] || Ecto.UUID.generate()

      %{
        iss: client_id,
        client_id: client_id,
        session_metadata: %{client_session: client_session},
        redirect_uri: Config.consent_redirect_url(config_name) |> URI.to_string()
      }
      |> generate_and_sign!(Config.signer(config_name))
    end
  end

  @doc """
  Generates a consent link using Stone Open Bank specification.
  """
  @spec generate_link(config_name :: atom(), opts :: Keyword.t()) :: String.t()
  def generate_link(config_name, opts \\ []) do
    query =
      %{
        client_id: Config.client_id(config_name),
        type: "consent",
        jwt: Token.generate(config_name, opts)
      }
      |> URI.encode_query()

    link = config_name |> Config.accounts_url() |> URI.parse()

    %{link | query: query, path: "/consentimento"} |> URI.to_string()
  end
end
