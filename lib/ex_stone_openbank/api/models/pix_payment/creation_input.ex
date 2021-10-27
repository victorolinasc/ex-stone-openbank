defmodule ExStoneOpenbank.API.Model.PixPayment.CreationInput do
  @moduledoc false

  use ExStoneOpenbank.Model

  alias ExStoneOpenbank.API.Model.PixPayment.CreationInput.Target

  @fields [:account_id, :amount, :idempotency_key]
  @optional [:description, :key]

  embedded_schema do
    field :account_id
    field :amount, :integer
    field :description
    field :key
    field :idempotency_key

    embeds_one :target, Target
  end

  @doc false
  def changeset(model \\ %__MODULE__{}, params) do
    model
    |> cast(params, @fields ++ @optional)
    |> cast_embed(:target)
    |> validate_required(@fields)
    |> validate_target_presence()
  end

  defp validate_target_presence(%Ecto.Changeset{valid?: true} = changeset) do
    key = get_change(changeset, :key)
    target = get_change(changeset, :target)

    if is_nil(key) and is_nil(target) do
      add_error(changeset, :target, ":target or :key must be set")
    else
      changeset
    end
  end

  defp validate_target_presence(changeset), do: changeset
end
