defmodule ExStoneOpenbank.API.Model.StatementTest do
  use ExUnit.Case, async: true

  alias ExStoneOpenbank.API.Model.StatementEntry

  test "can parse" do
    map =
      ~s({"amount":50,"balance_after":681776564,"balance_before":681776514,"counter_party":{"account":{"account_code":"125746237705","branch_code":"1","institution":"16501555","institution_name":"Stone Pagamentos S.A."},"entity":{"name":"Luiz Carlos Pires de Oliveira Junior"}},"created_at":"2020-01-10T15:51:48Z","description":"","id":"d4112274-d597-484b-a386-701ba86b92e3","operation":"credit","status":"FINISHED","type":"internal"})
      |> Jason.decode!()

    assert StatementEntry.changeset(map) |> Map.get(:valid?)
  end
end
