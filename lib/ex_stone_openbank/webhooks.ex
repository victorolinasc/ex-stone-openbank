defmodule ExStoneOpenbank.Webhooks do
  @moduledoc """
  Handles incoming webhooks.

  A webhook is a JSON object with only the key encrypted_body and a JWE as its value.

  The algorithm used is RSA-OAEP-256 of the JWA specification.
  """

  alias ExStoneOpenbank.Config
  alias ExStoneOpenbank.Webhooks.StoneJWTConfig

  @doc """
  Validate and open the webhook payload.

  First, it decrypts using our private key. Then, we validate the contents with a known
  public key (see `ExStoneOpenbank.Webhooks.StoneJWKS`). If all is valid, we return the
  contents.

  This function needs a recent OTP version compiled with a recent OpenSSL library version.
  """
  @spec incoming(config_name :: atom(), webhook :: map()) ::
          {:ok, map()} | {:error, reason :: atom()}
  def incoming(config_name, %{"encrypted_body" => encrypted_webhook}) do
    with %{jwk: jwk} <- Config.signer(config_name),
         {jwt, _} <- JOSE.JWE.block_decrypt(jwk, encrypted_webhook),
         {:ok, webhook} <- StoneJWTConfig.verify_and_validate(jwt) do
      {:ok, webhook}
    else
      _ -> {:error, :bad_webhook_payload}
    end
  end
end
