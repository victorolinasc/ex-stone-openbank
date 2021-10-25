defmodule ExStoneOpenbank.Authenticator.AuthHTTPMiddlewareTest do
  use ExStoneOpenbank.Case

  alias ExStoneOpenbank.{Authenticator, HTTP}

  setup :set_mox_global
  setup :set_test_client

  describe "call/3" do
    test "succeeds when there is a proper token and successful response", ctx do
      start_authenticator(ctx)

      expect_call(fn env ->
        assert URI.parse(env.url).path == "/api/v1/some_resource"
        json_response(%{})
      end)

      assert HTTP.get(ctx.opts[:name], "/some_resource") == {:ok, %{}}
    end

    test "tries re-authentication upon a 401", ctx do
      # We expect 4 calls on this test:
      # 1. First authentication
      # 2. First attempt at GET which we simulate a 401
      # 3. New authentication
      # 4. Next attempt at GET with the new token
      expect_call(4, fn
        %{method: :post, headers: [{"content-type", "application/x-www-form-urlencoded"}]} = env ->
          # To know if this is the first time we check if already have tokens
          case Authenticator.access_token(ctx.opts[:name]) do
            {:ok, "token"} ->
              response = json_response(%{access_token: "new_token"})
              assert_authentication(ctx.opts[:client_id], response, env)

            {:error, :unauthenticated} ->
              response = json_response(%{access_token: "token"})
              assert_authentication(ctx.opts[:client_id], response, env)
          end

        env ->
          assert URI.parse(env.url).path == "/api/v1/some_resource"

          # If the token is from the first call we simulate a 401
          if Authenticator.access_token(ctx.opts[:name]) == {:ok, "token"},
            do: json_response(%{}, 401),
            else: json_response(%{})
      end)

      start_supervised!({ExStoneOpenbank.Authenticator, ctx.opts})
      :timer.sleep(200)

      assert HTTP.get(ctx.opts[:name], "/some_resource") == {:ok, %{}}
    end
  end
end
