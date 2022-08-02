defmodule ExStoneOpenbank.Webhooks.StoneJWKS do
  @moduledoc """
  A token configuration used to verify the JWT token signed by Stone.
  """
  use JokenJwks.DefaultStrategyTemplate

  alias ExStoneOpenbank.Config

  @doc false
  def init_opts(opts) do
    url = Config.api_url(opts[:name])

    Keyword.merge(opts,
      jwks_url: "#{url}/api/v1/discovery/keys",
      explicit_alg: "RS256",
      log_level: :warn
    )
  end
end
