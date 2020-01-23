defmodule ExStoneOpenbank.API.Model.TransferTarget do
  @moduledoc """
  Target of a transfer.
  """
  use ExStoneOpenbank.Model

  alias ExStoneOpenbank.API.Model.{TransferAccount, TransferEntity}

  @fields []
  @optional []

  embedded_schema do
    embeds_one :account, TransferAccount
    embeds_one :entity, TransferEntity
  end

  @doc false
  def changeset(model \\ %__MODULE__{}, params) do
    model
    |> cast(params, @fields ++ @optional)
    |> cast_embed(:account, required: true)
    |> cast_embed(:entity)
  end
end
