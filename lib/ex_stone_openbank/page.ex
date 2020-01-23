defmodule ExStoneOpenbank.Page do
  @moduledoc """
  A page on any cursor based paginated API.
  """
  use ExStoneOpenbank.Model
  alias ExStoneOpenbank.Cursor

  embedded_schema do
    embeds_one :cursor, Cursor
    field :data, {:array, :map}
    field :function, :any, virtual: true
  end

  @doc false
  def changeset(model \\ %__MODULE__{}, params) do
    model
    |> cast(params, [:data])
    |> cast_embed(:cursor)
  end

  @doc false
  def parse_data_model(%__MODULE__{} = page, model) do
    %{page | data: Enum.map(page.data, &model.cast_and_apply(&1))}
  end

  def has_next?(page), do: not is_nil(page.cursor.after)
  def has_before(page), do: not is_nil(page.cursor.before)

  def first(function), do: call_and_wrap_function(:first, %Cursor{}, function)

  def next(page) do
    if page.cursor.after do
      call_and_wrap_function(:after, page.cursor, page.function)
    else
      {:error, :no_more_pages}
    end
  end

  def before(page) do
    if page.cursor.before do
      call_and_wrap_function(:before, page.cursor, page.function)
    else
      {:error, :no_more_pages}
    end
  end

  defp call_and_wrap_function(type, param, function) do
    type
    |> function.(param)
    |> case do
      {:ok, page} -> {:ok, %{page | function: function}}
      err -> err
    end
  end
end
