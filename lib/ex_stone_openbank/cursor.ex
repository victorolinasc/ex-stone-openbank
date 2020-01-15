defmodule ExStoneOpenbank.Cursor do
  @moduledoc """
  Cursor pagination.
  """

  use ExStoneOpenbank.Model

  @default_limit 50

  @fields [:after, :before, :limit]

  embedded_schema do
    field :after, :string
    field :before, :string
    field :limit, :integer
  end

  def changeset(model \\ %__MODULE__{}, params) do
    model
    |> cast(params, @fields)
  end

  def parse_opts(:first, cursor, http_opts),
    do: add_params(http_opts, limit: cursor.limit || @default_limit)

  def parse_opts(:after, cursor, http_opts),
    do: add_params(http_opts, limit: cursor.limit || @default_limit, after: cursor.after)

  def parse_opts(:before, cursor, http_opts),
    do: add_params(http_opts, limit: cursor.limit || @default_limit, before: cursor.before)

  defp add_params([], params), do: [query: params]

  defp add_params(http_opts, params) do
    Keyword.put(
      http_opts,
      :query,
      if http_opts[:query] do
        Keyword.merge(params, http_opts[:query])
      else
        params
      end
    )
  end
end
