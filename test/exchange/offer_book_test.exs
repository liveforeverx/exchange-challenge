defmodule Exchange.OfferBookTest do
  use ExUnit.Case

  alias Exchange.OfferBook

  describe "get/2" do
    test "get empty offer" do
      book = %OfferBook{}
      assert %{price: 0.0, quantity: 0} = OfferBook.get(book, 1)
      assert %{price: 0.0, quantity: 0} = OfferBook.get(book, 10)
    end
  end

  describe "new/4" do
    test "add new offer to an empty book" do
      book = %OfferBook{}
      assert {:ok, book} = OfferBook.new(book, 1, 50.0, 30)
      assert %{price: 50.0, quantity: 30} = OfferBook.get(book, 1)
    end

    test "add new offer with equal price level" do
      book = %OfferBook{}
      assert {:ok, book} = OfferBook.new(book, 1, 50.0, 30)
      assert {:ok, book} = OfferBook.new(book, 1, 70.0, 30)
      assert %{price: 70.0, quantity: 30} = OfferBook.get(book, 1)
    end

    test "add new offer with greater price level" do
      book = %OfferBook{}
      assert {:ok, book} = OfferBook.new(book, 1, 50.0, 30)
      assert {:ok, book} = OfferBook.new(book, 2, 70.0, 30)
      assert %{price: 50.0, quantity: 30} = OfferBook.get(book, 1)
      assert %{price: 70.0, quantity: 30} = OfferBook.get(book, 2)
    end
  end

  describe "update/4" do
    test "update offer with non-existing price level" do
      book = %OfferBook{}
      assert {:error, :not_found} = OfferBook.update(book, 1, 50.0, 30)
    end

    test "update offer with existing price level" do
      book = %OfferBook{}
      assert {:ok, book} = OfferBook.new(book, 1, 50.0, 30)
      assert {:ok, book} = OfferBook.update(book, 1, 70.0, 30)
      assert %{price: 70.0, quantity: 30} = OfferBook.get(book, 1)
    end

    test "update offer with different price level" do
      book = %OfferBook{}
      assert {:ok, book} = OfferBook.new(book, 1, 50.0, 30)
      assert {:error, :not_found} = OfferBook.update(book, 2, 70.0, 30)
    end
  end

  describe "delete/2" do
    test "delete non-existing price level" do
      book = %OfferBook{}
      assert {:ok, book} = OfferBook.delete(book, 1)
    end

    test "delete existing offer with a price level" do
      book = %OfferBook{}
      assert {:ok, book} = OfferBook.new(book, 1, 50.0, 30)
      assert {:ok, book} = OfferBook.delete(book, 1)
      assert %{price: 0.0, quantity: 0} = OfferBook.get(book, 1)
    end

    test "delete several offers with the same price level" do
      book = %OfferBook{}
      assert {:ok, book} = OfferBook.new(book, 1, 50.0, 30)
      assert {:ok, book} = OfferBook.new(book, 1, 70.0, 30)
      assert {:ok, book} = OfferBook.delete(book, 1)
      assert %{price: 0.0, quantity: 0} = OfferBook.get(book, 1)
    end
  end
end
