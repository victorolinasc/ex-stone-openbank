defmodule ExStoneOpenbank.API.Model.TransferInput do
  @moduledoc """
  Internal transfer input model.
  """
  use ExStoneOpenbank.Model

  alias ExStoneOpenbank.API.Model.TransferTarget

  @fields [:amount, :account_id]
  @optional [:description, :scheduled_to]

  embedded_schema do
    field :amount, :integer
    field :account_id, :string

    field :description, :string
    field :scheduled_to, :date

    field :type, :string, virtual: true

    embeds_one :target, TransferTarget
  end

  @doc false
  def changeset(model \\ %__MODULE__{}, params) do
    model
    |> cast(params, @fields ++ @optional)
    |> cast_embed(:target, required: true)
    |> validate_required(@fields)
    |> cast_type()
  end

  defp cast_type(%{valid?: false} = changeset), do: changeset

  defp cast_type(changeset) do
    target = fetch_field!(changeset, :target)

    type =
      case target do
        %{account: %{institution_code: code}} when code != "197" -> "external_transfer"
        _ -> "internal_transfer"
      end

    put_change(changeset, :type, type)
  end
end
