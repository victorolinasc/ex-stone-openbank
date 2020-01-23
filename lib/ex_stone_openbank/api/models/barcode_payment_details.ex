defmodule ExStoneOpenbank.API.Model.BarcodePaymentDetails do
  @moduledoc """
  Details about the barcode payment
  """
  use ExStoneOpenbank.Model

  @fields [
    :barcode,
    :status,
    :writable_line
  ]

  @optional [
    :value,
    :bank_name,
    :expiration_date,
    :face_value,
    :favored,
    :recipient_cpf_cnpj,
    :recipient_name
  ]

  embedded_schema do
    field :bank_name, :string
    field :barcode, :string
    field :expiration_date, :string
    field :face_value, :integer
    field :favored, :string
    field :recipient_cpf_cnpj, :string
    field :recipient_name, :string
    field :status, :string
    field :value, :integer
    field :writable_line, :string
  end

  @doc false
  def changeset(model \\ %__MODULE__{}, params) do
    model
    |> cast(params, @fields ++ @optional)
    |> validate_required(@fields)
  end
end
