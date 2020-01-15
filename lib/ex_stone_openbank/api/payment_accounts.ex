defmodule ExStoneOpenbank.API.PaymentAccounts do
  @moduledoc """
  Retrieves all resources the application has access to.
  """

  alias ExStoneOpenbank.API.Model.{PaymentAccount, Statement}
  alias ExStoneOpenbank.{Cursor, HTTP, Page}

  def list(name, opts \\ []) do
    Page.first(
      &HTTP.get(name, "/accounts?paginate=true", Cursor.parse_opts(&1, &2, opts),
        model: PaymentAccount
      )
    )
  end

  def list_statements(name, account_id, opts \\ []) do
    Page.first(
      &HTTP.get(
        name,
        "/accounts/#{account_id}/statement?paginate=true",
        Cursor.parse_opts(&1, &2, opts),
        model: Statement
      )
    )
  end
end
