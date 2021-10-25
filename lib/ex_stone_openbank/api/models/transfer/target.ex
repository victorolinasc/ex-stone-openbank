defmodule ExStoneOpenbank.API.Model.Transfer.Target do
  @moduledoc """
  Target of a transfer.
  """
  use ExStoneOpenbank.Model

  alias ExStoneOpenbank.API.Model.Transfer.Target.{Account, Entity}

  @fields []
  @optional []

  embedded_schema do
    embeds_one :account, Account
    embeds_one :entity, Entity
  end

  @doc false
  def changeset(model \\ %__MODULE__{}, params) do
    model
    |> cast(params, @fields ++ @optional)
    |> cast_embed(:account, required: true)
    |> cast_embed(:entity)
  end
end
