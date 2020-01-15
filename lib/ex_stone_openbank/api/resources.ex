defmodule ExStoneOpenbank.API.Resources do
  @moduledoc """
  Retrieves all resources the application has access to.
  """

  alias ExStoneOpenbank.API.Model.Permission
  alias ExStoneOpenbank.{Cursor, HTTP, Page}

  @spec list(config_name :: atom(), filter_opts :: Keyword.t()) ::
          {:ok, Page.t()} | {:error, reason :: atom()}
  def list(name, opts \\ []) do
    Page.first(&HTTP.get(name, "/resources", Cursor.parse_opts(&1, &2, opts), model: Permission))
  end
end
