defmodule ExStoneOpenbank.API.Model.Permission do
  @moduledoc """
  Permission model
  """
  use ExStoneOpenbank.Model

  @fields [
    :created_at,
    :resource_id,
    :resource_type,
    :scope,
    :status,
    :subject_id,
    :subject_type
  ]

  embedded_schema do
    field :created_at, :naive_datetime
    field :resource_id, Ecto.UUID
    field :resource_type, :string
    field :scope, :string
    field :status, :string
    field :subject_id, :string
    field :subject_type, :string
  end

  def changeset(model \\ %__MODULE__{}, params) do
    model
    |> cast(params, @fields)
    |> validate_required(@fields)
  end
end
