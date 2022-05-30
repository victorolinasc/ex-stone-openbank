defmodule ExStoneOpenbank.Case do
  @moduledoc false

  use ExUnit.CaseTemplate

  using do
    quote do
      import Mox
      import ExStoneOpenbank.JokenHelper
      import ExStoneOpenbank.TeslaHelper

      setup :verify_on_exit!

      def set_test_client(_context \\ %{}) do
        opts = [
          name: :test,
          client_id: "example_id",
          private_key: pem(),
          consent_redirect_url: "http://consent_test"
        ]

        {:ok, opts: opts}
      end

      def start_authenticator(%{opts: opts}) do
        expect_authentication(opts[:client_id])
        start_supervised!({ExStoneOpenbank.Authenticator, opts})
        :timer.sleep(200)
        {:ok, opts: opts}
      end
    end
  end
end
