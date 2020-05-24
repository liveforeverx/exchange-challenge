defmodule Exchange.OfferMatchTest do
  use ExUnit.Case

  alias Exchange.OfferBook
  alias Exchange.OfferMatch

  test "match offers" do
    ask_offers = %OfferBook{}
    {:ok, ask_offers} = OfferBook.new(ask_offers, 1, 60.0, 10)
    {:ok, ask_offers} = OfferBook.new(ask_offers, 2, 70.0, 10)

    bid_offers = %OfferBook{}
    {:ok, bid_offers} = OfferBook.new(bid_offers, 1, 50.0, 40)
    {:ok, bid_offers} = OfferBook.new(bid_offers, 2, 70.0, 20)

    assert OfferMatch.match(ask_offers, bid_offers, 2) == [
             %{ask_price: 60.0, ask_quantity: 10, bid_price: 50.0, bid_quantity: 40},
             %{ask_price: 70.0, ask_quantity: 10, bid_price: 70.0, bid_quantity: 20}
           ]
  end
end
