defmodule ExStoneOpenbank.ConsentsTest do
  use ExStoneOpenbank.Case, async: false

  alias ExStoneOpenbank.Consents

  setup :set_mox_global
  setup :set_test_client
  setup :start_authenticator

  describe "generate_link/2" do
    test "successfully generate link", ctx do
      assert link = Consents.generate_link(ctx.opts[:name])

      assert %URI{
               authority: "conta.stone.com.br",
               host: "conta.stone.com.br",
               path: "/consentimento",
               port: 443,
               query: query
             } = URI.parse(link)

      assert %{
               "client_id" => "example_id",
               "jwt" => _,
               "type" => "consent"
             } = URI.decode_query(query)
    end
  end
end
