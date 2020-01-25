defmodule ExStoneOpenbank.API.Model.BarcodePaymentResponse do
  @moduledoc """
  Response of a successful barcode payment (or a barcode payment dry-run)
  """
  use ExStoneOpenbank.Model
  alias ExStoneOpenbank.API.Model.BarcodePaymentDetails

  @fields [
    :account_id,
    :amount,
    :barcode,
    :created_at,
    :created_by,
    :fee,
    :status,
    :writable_line
  ]

  @optional [
    :id,
    :approval_expired_at,
    :approved_at,
    :approved_by,
    :failed_at,
    :failure_reason_code,
    :failure_reason_description,
    :cancelled_at,
    :refunded_at,
    :rejected_at,
    :rejected_by,
    :scheduled_to,
    :finished_at
  ]

  embedded_schema do
    field :account_id, :string
    field :amount, :integer
    field :approval_expired_at, :naive_datetime
    field :approved_at, :naive_datetime
    field :approved_by, :string
    field :barcode, :string
    field :cancelled_at, :naive_datetime
    field :created_at, :naive_datetime
    field :created_by, :string

    field :failed_at, :naive_datetime
    field :failure_reason_code, :string
    field :failure_reason_description, :string
    field :fee, :integer
    field :finished_at, :naive_datetime
    field :id, :string
    field :refunded_at, :naive_datetime
    field :rejected_at, :naive_datetime
    field :rejected_by, :string
    field :scheduled_to, :naive_datetime
    field :status, :string
    field :writable_line, :string

    embeds_one :details, BarcodePaymentDetails
  end

  @doc false
  def changeset(model \\ %__MODULE__{}, params) do
    model
    |> cast(params, @fields ++ @optional)
    |> cast_embed(:details)
    |> validate_required(@fields)
  end
end
