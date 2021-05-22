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

      assert_raise RuntimeError, "Invalid PEM string passed as private_key", fn ->
        Config.validate_and_persist([{:private_key, "Not a valid PEM encoded RSA key"} | opts])
      end

      public_rsa_pem = """
      -----BEGIN PRIVATE KEY-----
      MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAqU8qSyDQnaCOc7oBQQ5z
      5vplJfgh+3e88XIymUhXUNbOGAkrYKXrizX4acjx82Xr0p7LCtIner2zP/zzVhxP
      7k6EiZ6ugQ8wfakWGJXfK2EgO4HSzFBNhTYXTCZ5K72CiDi6O+XFGo7e34BzYZS1
      u1dv6pOK7JKeLuZInZk48Vlm6dXWOPISYbCrFEjyqdFqltXMdqo9ciZ8eRUIG9lY
      X+8B3LjI5tn1lc7Jjr6SHUTJM2OySKafKzWH7K0JaZTe9T2KoB+U2U5HXFl3CUfn
      zoPBJJC0y19dUYRCKGmhZJLAojm4nnp+6Ul8M1P6W8lqzycWNancR5k/hUYigK7P
      ywIDAQAB
      -----END PRIVATE KEY-----
      """

      assert_raise(RuntimeError, fn ->
        Config.validate_and_persist([{:private_key, public_rsa_pem} | opts])
      end).message =~ "Bad private key. Threw error: "
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
