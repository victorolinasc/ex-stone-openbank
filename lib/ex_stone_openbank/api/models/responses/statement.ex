defmodule ExStoneOpenbank.API.Model.Statement do
  @moduledoc """
  Statement model
  """
  use ExStoneOpenbank.Model
  alias ExStoneOpenbank.API.Model.CounterParty

  @fields [
    :amount,
    :balance_after,
    :balance_before,
    :id,
    :operation,
    :status,
    :created_at,
    :type
  ]

  @optional [
    :description
  ]

  embedded_schema do
    field :amount, :integer
    field :balance_after, :integer
    field :balance_before, :integer
    field :created_at, :naive_datetime
    field :description, :string
    field :id, Ecto.UUID
    field :operation, :string
    field :status, :string
    field :type, :string

    embeds_one :counter_party, CounterParty
  end

  @doc false
  def changeset(model \\ %__MODULE__{}, params) do
    model
    |> cast(params, @fields ++ @optional)
    |> cast_embed(:counter_party)
    |> validate_required(@fields)
  end
end
