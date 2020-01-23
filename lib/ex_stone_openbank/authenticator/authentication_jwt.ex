defmodule ExStoneOpenbank.Authenticator.AuthenticationJWT do
  @moduledoc """
  Responsible for the JWT generation used in the client_credentials authentication flow.
  """
  use Joken.Config

  @impl true
  def token_config do
    [skip: [:iss, :aud]]
    |> default_claims()
    |> add_claim("realm", fn -> "stone_bank" end)
  end
end
