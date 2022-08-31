defmodule ExStoneOpenbank.API.Model.PixPayment.CreationInput.Target do
  @moduledoc false

  use ExStoneOpenbank.Model

  alias ExStoneOpenbank.API.Model.PixPayment.CreationInput.Target.{Account, Entity, Institution}

  embedded_schema do
    embeds_one :account, Account
    embeds_one :entity, Entity
    embeds_one :institution, Institution
  end

  @doc false
  def changeset(model \\ %__MODULE__{}, params) do
    model
    |> cast(params, [])
    |> cast_embed(:account, required: true)
    |> cast_embed(:entity)
    |> cast_embed(:institution, required: true)
  end
end
