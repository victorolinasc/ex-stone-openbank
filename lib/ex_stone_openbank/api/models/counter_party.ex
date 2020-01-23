defmodule ExStoneOpenbank.API.Model.CounterParty do
  @moduledoc """
  Counter party model
  """

  use ExStoneOpenbank.Model

  alias ExStoneOpenbank.API.Model.{Account, Entity}

  embedded_schema do
    embeds_one :account, Account
    embeds_one :entity, Entity
  end

  @doc false
  def changeset(model \\ %__MODULE__{}, params) do
    model
    |> cast(params, [])
    |> cast_embed(:account)
    |> cast_embed(:entity)
  end
end
