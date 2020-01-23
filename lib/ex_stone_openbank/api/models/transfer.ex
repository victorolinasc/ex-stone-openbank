defmodule ExStoneOpenbank.API.Model.TransferResponse do
  @moduledoc """
  A transfer representation
  """
  use ExStoneOpenbank.Model

  alias ExStoneOpenbank.API.Model.TransferTarget

  @fields [
    :amount,
    :created_at,
    :created_by,
    :fee,
    :id,
    :status
  ]
  @optional [
    :approval_expired_at,
    :approved_at,
    :approved_by,
    :cancelled_at,
    :delayed_to_next_business_day,
    :failed_at,
    :finished_at,
    :refund_reason_code,
    :refund_reason_description,
    :refunded_at,
    :rejected_at,
    :rejected_by,
    :scheduled_to_effective,
    :scheduled_to_requested
  ]

  embedded_schema do
    field :amount, :integer
    field :approval_expired_at, :naive_datetime
    field :approved_at, :naive_datetime
    field :approved_by, :string
    field :cancelled_at, :naive_datetime
    field :created_at, :naive_datetime
    field :created_by, :string
    field :delayed_to_next_business_day, :boolean
    field :failed_at, :naive_datetime
    field :fee, :integer
    field :finished_at, :naive_datetime
    field :id, :string
    field :refund_reason_code, :string
    field :refund_reason_description, :string
    field :refunded_at, :naive_datetime
    field :rejected_at, :naive_datetime
    field :rejected_by, :string
    field :scheduled_to_effective, :date
    field :scheduled_to_requested, :string
    field :status, :string
    embeds_one :target, TransferTarget
  end

  @doc false
  def changeset(model \\ %__MODULE__{}, params) do
    model
    |> cast(params, @fields ++ @optional)
    |> cast_embed(:target, required: true)
  end
end
