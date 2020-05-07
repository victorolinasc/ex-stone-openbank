defmodule ExStoneOpenbank.API.Model.PaymentAccount do
  @moduledoc """
  PaymentAccount model
  """
  use ExStoneOpenbank.Model

  @fields [
    :account_code,
    :branch_code,
    :id,
    :owner_document,
    :owner_id,
    :owner_name,
    :restricted_features,
    :status
  ]

  embedded_schema do
    field :account_code, :string
    field :branch_code, :string
    field :id, Ecto.UUID
    field :owner_document, :string
    field :owner_id, :string
    field :owner_name, :string
    field :status, :string
  end

  @doc false
  def changeset(model \\ %__MODULE__{}, params) do
    model
    |> cast(params, @fields)
    |> validate_required(@fields)
  end
end
