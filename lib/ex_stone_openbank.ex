defmodule ExStoneOpenbank do
  @moduledoc """
  ExStoneOpenbank is a library for calling Stone Open Bank APIs.

  In order to use this library you need to create an application profile. Please see docs of
  the service at https://docs.openbank.stone.com.br

  The steps to use this SDK are:

  1. Create a user and open a payment account on Stone Openbank;
  2. Create an application profile on Stone Openbank;
  3. Add this library to your application;
  4. Add configuration for your app(s);
  5. Start calling for your bank API.

  ## Registration

  For user registration, just follow the normal flow of signing up for the service. That includes:

  1. Register your user;
  2. Open a payment account;
  3. Wait for approval (you will be notified);
  4. Test your account using our web/mobile banking solutions;

  For application registration, you will need to submit some parameters. Please, refer to our API docs:

  https://docs.openbank.stone.com.br

  ## Library configuration

  First, add this as a dependency:

      {:ex_stone_openbank, "~> {{ latest version here }}"}

  The SDK does not start a supervision tree on its own. So, to configure it you need to add at
  least two servers to your main application's supervision tree. This is usually on a file named
  `application.ex`. Here is an example:


      defmodule MyApp.Application do
        @moduledoc false

        use Application

        def start(_type, _args) do
          children = [
            # important JWKS for webhooks! It only uses the :sandbox? key from the config.
            {ExStoneOpenbank.Webhooks.StoneJWKS, stone_bank()},
            # Your application authenticator
            {ExStoneOpenbank.Authenticator, stone_bank()},
            # ... other configurations like Repo, Endpoint and so on
          ]

          opts = [strategy: :one_for_one, name: MyApp.Supervisor]
          Supervisor.start_link(children, opts)
        end

        defp stone_bank do
          [
            name: :my_app,
            private_key: get_private_pem_key(), # fetch the key
            client_id: get_client_id(), # fetch the client_id
            sandbox?: true, # tells the environment of the application (see docs)
            consent_redirect_url: "my url" (only needed if consent is enabled)
          ]
        end
      end

  The possible configuration parameters are:

  - `name` (mandatory): will be used on all calls to `ExStoneOpenbank`
  - `private_key` (mandatory): must be a PEM encoded string
  - `client_id` (mandatory): the id of the application registration
  - `sandbox?` (optional, defaults to `false`): which environment the app is registered to
  - `consent_redirect_url` (optional): the URL the service will redirect to once consent is granted
  by a user

  ## Call APIs :)

  With that you are ready to call any APIs. Those are provided on the namespace `ExStoneopenbank.API`.
  For example:

  - `ExStoneOpenbank.API.PaymentAccounts`: has functions to work with balances, list all accounts and
  so on
  - `ExStoneOpenbank.API.Payments`: pays barcode bankslips
  - `ExStoneOpenbank.API.Transfers`: makes internal (Stone account to Stone account) and external
  (Stone account to other institution)

  ... and so on!

  All APIs expect the config name as the first parameter. This is so to make it possible to have
  more than one Stone application, each with its own authenticator.

  ## Cursor-based pagination endpoints

  We use cursor-based pagination for list endpoints. Therefore, all endpoints that return a
  `ExStoneOpenbank.Page` will have:

  - `data`: the list of items retrieved
  - `cursor`: details about the next/before pages and the limit used

  You can keep paginating with `ExStoneOpenbank.Page.next/1` and `ExStoneOpenbank.Page.before/1`
  passing the page result.

  Here is an example:

      account_id = # some id
      {:ok, page} = ExStoneOpenbank.API.PaymentAccounts.list_statements(:my_app, account_id, limit: 50)
      page.data # => items

      # Suppose there are enought items for paginating (if not the response is {:error, :no_more_pages})
      {:ok, page2} = ExStoneOpenbank.Page.next(page)
      {:ok, ^page} = ExStoneOpenbank.Page.before(page2)

      # You can also query the state before attempting the call
      ExStoneOpenbank.Page.has_next?(page) # => true | false
  """
end
