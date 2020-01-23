defmodule ExStoneOpenbank.Authenticator.AuthHTTPMiddleware do
  @moduledoc """
  A Tesla Middleware that ensures we always have a valid access_token.

  This middleware implementation has a retryable approach. It tries the call with the current token
  available. It might get a 401 at first and so, it calls for a refresh on the authenticator. This
  may block if the authenticator is trying to renew the token. When it gets a possibly new token it
  will retry the same call with the new token. In the case that it fails again, it will repeat this
  flow for 5 times (configured default limit of retries). If it fails after that, it will return
  the error.

  This authentication flow is necessary to ensure we use the token the best way we can and avoid
  authenticating on every call.
  """

  alias ExStoneOpenbank.{Authenticator, HTTP}
  alias Tesla.Middleware

  @behaviour Middleware

  @impl true
  def call(env, stack, %{config_name: config_name}) do
    do_call(1, env, stack, config_name)
  end

  defp do_call(attempt, env, stack, config_name) when attempt < 5 do
    with {:ok, access_token} <- Authenticator.access_token(config_name),
         result <-
           Tesla.run(
             %{env | headers: [{"Authorization", "Bearer #{access_token}"} | env.headers]},
             stack
           ) do
      result
      |> HTTP.parse_result()
      |> case do
        {:error, :unauthenticated} ->
          millis = Authenticator.time_until_next_refresh(config_name)

          if millis > 0, do: :timer.sleep(millis)

          Authenticator.refresh_token(config_name)
          do_call(attempt + 1, env, stack, config_name)

        _ ->
          result
      end
    end
  end

  defp do_call(_attempt, _env, _stack, _config_name), do: {:error, :unauthenticated}
end
