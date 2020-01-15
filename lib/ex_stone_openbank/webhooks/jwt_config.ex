defmodule ExStoneOpenbank.Webhooks.StoneJWTConfig do
  @moduledoc """
  A webhook arrives as an encrypted token (JWE). After decrypting it we get a JWT signed by
  Stone's public keys. We must validate its signature so that we can use the payload.
  """
  use Joken.Config

  alias ExStoneOpenbank.Webhooks.StoneJWKS

  add_hook(JokenJwks, strategy: StoneJWKS)

  @impl true
  def token_config, do: default_claims(default_exp: 5 * 60, skip: [:aud, :iss])
end
