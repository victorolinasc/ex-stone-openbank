defmodule ExStoneOpenbank.ConfigTest do
  use ExUnit.Case, async: true

  alias ExStoneOpenbank.Config

  describe "validate_and_persist/1" do
    test "validates invalid config_name" do
      assert_raise RuntimeError, "Name must be an atom", fn ->
        Config.validate_and_persist(name: "not an atom")
      end

      assert_raise RuntimeError, "Name must be an atom", fn ->
        Config.validate_and_persist(name: 12_312_345)
      end

      assert_raise RuntimeError, "Name must be an atom", fn ->
        Config.validate_and_persist(name: nil)
      end

      assert_raise RuntimeError, "Name must be an atom", fn ->
        Config.validate_and_persist(name: false)
      end
    end

    test "validates invalid client_id" do
      opts = [name: :some]

      assert_raise RuntimeError, "Client ID is mandatory and must be a string", fn ->
        Config.validate_and_persist([{:client_id, :not_a_string} | opts])
      end

      assert_raise RuntimeError, "Client ID is mandatory and must be a string", fn ->
        Config.validate_and_persist([{:client_id, 1325} | opts])
      end

      assert_raise RuntimeError, "Client ID is mandatory and must be a string", fn ->
        Config.validate_and_persist([{:client_id, nil} | opts])
      end
    end

    test "validates invalid sandbox?" do
      opts = [name: :some, client_id: "some id"]

      assert_raise RuntimeError, "`:sandbox?` must be a boolean or nil", fn ->
        Config.validate_and_persist([{:sandbox?, :not_a_boolean} | opts])
      end

      assert_raise RuntimeError, "`:sandbox?` must be a boolean or nil", fn ->
        Config.validate_and_persist([{:sandbox?, 1325} | opts])
      end

      assert_raise RuntimeError, "`:sandbox?` must be a boolean or nil", fn ->
        Config.validate_and_persist([{:sandbox?, "nil"} | opts])
      end
    end

    test "validates invalid private_key" do
      opts = [name: :some, client_id: "some id"]
      message = "Private key must be a String with a PEM encoded RSA private key"

      assert_raise RuntimeError, message, fn ->
        Config.validate_and_persist([{:private_key, :not_a_string} | opts])
      end

      assert_raise RuntimeError, message, fn ->
        Config.validate_and_persist([{:private_key, 12_345} | opts])
      end
    end

    test "validates invalid consent_redirect_url" do
      opts = [name: :some, client_id: "some id"]
      message = "Invalid argument for consent_redirect_url"

      assert_raise RuntimeError, message, fn ->
        Config.validate_and_persist([{:consent_redirect_url, :not_a_string} | opts])
      end

      assert_raise RuntimeError, message, fn ->
        Config.validate_and_persist([{:consent_redirect_url, 12_345} | opts])
      end

      assert_raise RuntimeError, "Invalid consent_redirect_url", fn ->
        Config.validate_and_persist([{:consent_redirect_url, "Not a valid URL"} | opts])
      end
    end
  end
end
