defmodule ExStoneOpenbank.Authenticator.AuthenticationJWT do
  @moduledoc """
  Responsible for the JWT generation used in the client_credentials authentication flow.
  """
  use Joken.Config

  alias ExStoneOpenbank.Config

  @impl true
  def token_config do
    default_claims(skip: [:iss, :aud])
    |> add_claim("realm", fn -> "stone_bank" end)
  end
end
