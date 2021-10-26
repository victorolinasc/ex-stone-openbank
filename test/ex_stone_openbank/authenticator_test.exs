defmodule ExStoneOpenbank.AuthenticatorTest do
  use ExStoneOpenbank.Case

  alias ExStoneOpenbank.Authenticator

  setup :set_mox_global
  setup :set_test_client
  setup :start_authenticator

  describe "init/1 and handle_continue/1" do
    test "tries authentication upon start", ctx do
      # started on setup block
      assert Authenticator.tokens(ctx.opts[:name]) == %{
               access_token: "token"
             }
    end
  end

  describe "handle_call/3 - :refresh_token" do
    test "do not re-authenticate if it did not pass time skew", ctx do
      assert Authenticator.refresh_token(ctx.opts[:name]) == %{
               access_token: "token"
             }
    end

    test "re-authenticates if more than skew time has passed", ctx do
      :timer.sleep(Authenticator.time_skew())

      expect_authentication(
        ctx.opts[:client_id],
        json_response(%{access_token: "new_token"})
      )

      assert Authenticator.refresh_token(ctx.opts[:name]) == %{
               access_token: "new_token"
             }
    end
  end
end
