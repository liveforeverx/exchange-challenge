defmodule Exchange.OfferMatch do
  alias Exchange.OfferBook

  @type match :: %{
          bid_price: float(),
          bid_quantity: integer(),
          ask_price: float(),
          ask_quantity: integer()
        }

  @spec match(OfferBook.t(), OfferBook.t(), integer()) :: [match()]
  def match(ask_offers, bid_offers, depth) when depth > 0 do
    for index <- 1..depth do
      bid_offer = OfferBook.get(bid_offers, index)
      ask_offer = OfferBook.get(ask_offers, index)

      %{
        bid_price: bid_offer.price,
        bid_quantity: bid_offer.quantity,
        ask_price: ask_offer.price,
        ask_quantity: ask_offer.quantity
      }
    end
  end
end
