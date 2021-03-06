# Copyright 2018-2019 OmiseGO Pte Ltd
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

defmodule EWalletDB.TokenTest do
  use EWalletDB.SchemaCase, async: true
  import EWalletDB.Factory
  alias ActivityLogger.System
  alias EWalletDB.{Token, Repo}

  describe "Token factory" do
    test_has_valid_factory(Token)
    test_encrypted_map_field(Token, "token", :encrypted_metadata)
  end

  describe "insert/1" do
    test_insert_generate_uuid(Token, :uuid)
    test_insert_generate_uuid(Token, :account_uuid)
    test_insert_generate_timestamps(Token)
    test_insert_prevent_blank(Token, :symbol)
    test_insert_prevent_blank(Token, :name)
    test_insert_prevent_blank(Token, :subunit_to_unit)
    test_default_metadata_fields(Token, "token")

    test_insert_field_length(Token, :symbol)
    test_insert_field_length(Token, :iso_code)
    test_insert_field_length(Token, :name)
    test_insert_field_length(Token, :description)
    test_insert_field_length(Token, :short_symbol)
    test_insert_field_length(Token, :subunit)
    test_insert_field_length(Token, :html_entity)
    test_insert_field_length(Token, :iso_numeric)
    test_insert_field_length(Token, :blockchain_address)

    test "generates an id with the schema prefix and token symbol" do
      {:ok, token} = :token |> params_for(id: nil, symbol: "OMG") |> Token.insert()

      assert "tok_OMG_" <> ulid = token.id
      # A ULID has 26 characters and are lower cases
      assert String.length(ulid) == 26
      assert ulid == String.downcase(ulid)
    end

    test "allow subunit to be set between 0 and 1.0e18" do
      {:ok, token} =
        :token |> params_for(subunit_to_unit: 1_000_000_000_000_000_000) |> Token.insert()

      assert token.subunit_to_unit == 1_000_000_000_000_000_000
    end

    test "fails to insert when subunit is equal to 1.0e19" do
      {:error, error} =
        :token |> params_for(subunit_to_unit: 10_000_000_000_000_000_000) |> Token.insert()

      assert error.errors == [
               subunit_to_unit:
                 {"must be less than or equal to %{number}",
                  [
                    validation: :number,
                    kind: :less_than_or_equal_to,
                    number: 1_000_000_000_000_000_000
                  ]}
             ]
    end

    test "fails to insert when subunit is inferior to 0" do
      {:error, error} = :token |> params_for(subunit_to_unit: -2) |> Token.insert()

      assert error.errors == [
               subunit_to_unit:
                 {"must be greater than %{number}",
                  [validation: :number, kind: :greater_than, number: 0]}
             ]
    end

    test "fails to insert when subunit is superior to 1.0e18" do
      {:error, error} =
        :token |> params_for(subunit_to_unit: 100_000_000_000_000_000_000_000) |> Token.insert()

      assert error.errors == [
               subunit_to_unit:
                 {"must be less than or equal to %{number}",
                  [
                    validation: :number,
                    kind: :less_than_or_equal_to,
                    number: 1_000_000_000_000_000_000
                  ]}
             ]
    end
  end

  describe "update/2" do
    test_update_field_length(Token, :iso_code)
    test_update_field_length(Token, :name)
    test_update_field_length(Token, :description)
    test_update_field_length(Token, :short_symbol)
    test_update_field_length(Token, :html_entity)
    test_update_field_length(Token, :iso_numeric)
    test_update_field_length(Token, :blockchain_address)

    test "updates an existing token correctly" do
      {:ok, token} =
        :token
        |> params_for(
          name: "OmiseGO",
          symbol: "OMG",
          iso_code: "OMG",
          description: "some description",
          short_symbol: "OM",
          symbol_first: true,
          html_entity: "some html entity",
          iso_numeric: "100",
          metadata: %{a_key: "a_value"},
          encrypted_metadata: %{a_key: "a_value"}
        )
        |> Token.insert()

      {:ok, updated_token} =
        Token.update(token, %{
          name: "OmiseGO updated",
          iso_code: "OMG updated",
          description: "some updated description",
          short_symbol: "OM updated",
          symbol_first: false,
          html_entity: "some updated html entity",
          iso_numeric: "100 updated",
          encrypted_metadata: %{},
          originator: %System{}
        })

      assert updated_token.name == "OmiseGO updated"
      assert updated_token.iso_code == "OMG updated"
      assert updated_token.description == "some updated description"
      assert updated_token.short_symbol == "OM updated"
      assert updated_token.symbol_first == false
      assert updated_token.html_entity == "some updated html entity"
      assert updated_token.iso_numeric == "100 updated"
      assert updated_token.metadata == %{"a_key" => "a_value"}
      assert updated_token.encrypted_metadata == %{}
    end

    test "Fails to update if name is nil" do
      {:ok, token} = :token |> params_for() |> Token.insert()
      {res, _error} = Token.update(token, %{name: nil})
      assert res == :error
    end
  end

  describe "all/0" do
    test "returns all existing tokens" do
      assert Enum.empty?(Token.all())

      :token |> params_for() |> Token.insert()
      :token |> params_for() |> Token.insert()
      :token |> params_for() |> Token.insert()

      assert length(Token.all()) == 3
    end
  end

  describe "query_all_blockchain/1" do
    test "returns a query of tokens that have a blockchain address" do
      assert Enum.empty?(Token.all())

      :token |> params_for(%{blockchain_address: "0x01"}) |> Token.insert()
      :token |> params_for(%{blockchain_address: "0x02"}) |> Token.insert()
      :token |> params_for() |> Token.insert()

      token_addresses =
        Token.query_all_blockchain()
        |> Repo.all()
        |> Enum.map(fn t -> t.blockchain_address end)

      assert length(token_addresses) == 2
      assert Enum.member?(token_addresses, "0x01")
      assert Enum.member?(token_addresses, "0x02")
    end
  end

  describe "query_all_by_blockchain_addresses/2" do
    test "returns a query of tokens that have an address matching in the provided list" do
      :token |> params_for(%{blockchain_address: "0x01"}) |> Token.insert()
      :token |> params_for(%{blockchain_address: "0x02"}) |> Token.insert()
      :token |> params_for(%{blockchain_address: "0x03"}) |> Token.insert()
      :token |> params_for() |> Token.insert()

      token_addresses =
        ["0x01", "0x02"]
        |> Token.query_all_by_blockchain_addresses()
        |> Repo.all()
        |> Enum.map(fn t -> t.blockchain_address end)

      assert length(token_addresses) == 2

      assert Enum.member?(token_addresses, "0x01")
      assert Enum.member?(token_addresses, "0x02")
      refute Enum.member?(token_addresses, "0x03")
    end
  end

  describe "query_all_by_ids/2" do
    test "returns a query of tokens that have an id matching in the provided list" do
      {:ok, tk_1} = :token |> params_for() |> Token.insert()
      {:ok, tk_2} = :token |> params_for() |> Token.insert()
      {:ok, tk_3} = :token |> params_for() |> Token.insert()
      {:ok, _tk_4} = :token |> params_for() |> Token.insert()

      token_ids =
        [tk_1.id, tk_2.id]
        |> Token.query_all_by_ids()
        |> Repo.all()
        |> Enum.map(fn t -> t.id end)

      assert length(token_ids) == 2

      assert Enum.member?(token_ids, tk_1.id)
      assert Enum.member?(token_ids, tk_2.id)
      refute Enum.member?(token_ids, tk_3.id)
    end
  end

  describe "get/1" do
    test "returns an existing token using a symbol" do
      {:ok, inserted} = :token |> params_for(id: nil, symbol: "sym") |> Token.insert()

      token = Token.get(inserted.id)
      assert "tok_sym_" <> _ = token.id
      assert token.symbol == "sym"
    end

    test "returns nil if the token does not exist" do
      token = Token.get("unknown")
      assert token == nil
    end
  end

  describe "enable_or_disable/0" do
    test "disables a token" do
      {:ok, token} = :token |> params_for() |> Token.insert()
      assert token.enabled == true

      {:ok, token} =
        Token.enable_or_disable(token, %{
          enabled: false,
          originator: %System{}
        })

      assert token.enabled == false
    end
  end
end
