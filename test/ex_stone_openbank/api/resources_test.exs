defmodule ExStoneOpenbank.API.ResourcesTest do
  use ExStoneOpenbank.Case

  alias ExStoneOpenbank.API.Resources
  alias ExStoneOpenbank.Page

  setup :set_mox_global
  setup :set_test_client
  setup :start_authenticator

  describe "list/2" do
    test "succeeds with properly parsed page", ctx do
      expect_call(fn %{method: :get, url: url, headers: headers} ->
        assert URI.parse(url).path == "/api/v1/resources"
        assert Enum.any?(headers, &match?({"Authorization", "Bearer token"}, &1))

        json_response(%{data: [], cursor: %{}})
      end)

      assert {:ok, %Page{}} = Resources.list(ctx.opts[:name])
    end
  end
end
