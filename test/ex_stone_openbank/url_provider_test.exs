defmodule ExStoneOpenbank.URLProviderTest do
  use ExUnit.Case, async: true

  alias ExStoneOpenbank.URLProvider

  @url_provider_params [
    accounts_url: "http://localhost/accounts",
    api_url: "http://localhost/api",
    conta_url: "http://localhost/conta"
  ]

  describe "build/2" do
    test "successfully build an URLProvider" do
      url_provider = URLProvider.build(:test, @url_provider_params)

      assert %URLProvider{
               accounts_url: "http://localhost/accounts",
               api_url: "http://localhost/api",
               conta_url: "http://localhost/conta"
             } = url_provider
    end

    test "always return static values for sandbox environment" do
      url_provider = URLProvider.build(:sandbox, @url_provider_params)

      assert %URLProvider{
               accounts_url: "https://sandbox-accounts.openbank.stone.com.br",
               api_url: "https://sandbox-api.openbank.stone.com.br",
               conta_url: "https://sandbox.conta.stone.com.br"
             } = url_provider
    end

    test "always return static values for production environment" do
      url_provider = URLProvider.build(:production, @url_provider_params)

      assert %URLProvider{
               accounts_url: "https://accounts.openbank.stone.com.br",
               api_url: "https://api.openbank.stone.com.br",
               conta_url: "https://conta.stone.com.br"
             } = url_provider
    end
  end
end
