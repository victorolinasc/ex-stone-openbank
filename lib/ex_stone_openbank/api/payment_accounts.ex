defmodule ExStoneOpenbank.API.PaymentAccounts do
  @moduledoc """
  Retrieves all resources the application has access to.
  """

  alias ExStoneOpenbank.API.Model.{PaymentAccount, StatementEntry}
  alias ExStoneOpenbank.{Cursor, HTTP, Page}

  @doc """
  List all accounts which the current token can access.
  """
  @spec list(config_name :: atom(), opts :: Keyword.t()) :: Page.t()
  def list(name, opts \\ []) do
    Page.first(
      &HTTP.get(name, "/accounts?paginate=true", Cursor.parse_opts(&1, &2, opts),
        model: PaymentAccount
      )
    )
  end

  @doc """
  Get the given account's statement as a paginated list.
  """
  @spec get_statement(
          config_name :: atom(),
          account_id :: String.t(),
          opts :: Keyword.t()
        ) :: Page.t()
  def get_statement(name, account_id, opts \\ []) do
    Page.first(
      &HTTP.get(
        name,
        "/accounts/#{account_id}/statement?paginate=true",
        Cursor.parse_opts(&1, &2, opts),
        model: StatementEntry
      )
    )
  end
end
