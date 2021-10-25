defmodule ExStoneOpenbank.API.Model.StatementEntry do
  @moduledoc """
  StatementEntry model
  """
  use ExStoneOpenbank.Model

  alias ExStoneOpenbank.API.Model.Statement.CounterParty

  @fields [
    :amount,
    :balance_after,
    :balance_before,
    :created_at,
    :id,
    :status
  ]

  @optional [
    :operation,
    :description,
    :type
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
