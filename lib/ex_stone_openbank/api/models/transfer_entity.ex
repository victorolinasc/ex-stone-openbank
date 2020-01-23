defmodule ExStoneOpenbank.API.Model.TransferEntity do
  @moduledoc """
  Account model
  """
  use ExStoneOpenbank.Model

  @fields [:name]
  @optional [:document, :document_type]

  embedded_schema do
    field :name, :string
    field :document, :string
    field :document_type, :string
  end

  @doc false
  def changeset(model \\ %__MODULE__{}, params) do
    model
    |> cast(params, @fields ++ @optional)
    |> validate_required(@fields)
    |> validate_inclusion(:document_type, ~w(cpf cnpj))
  end
end
