defmodule Exchange.OfferBook do
  alias Exchange.OfferBook

  @type price_level_index :: integer()
  @type price :: float()
  @type quantity :: integer()

  @type offer :: %{
          price_level_index: price_level_index(),
          price: price(),
          quantity: quantity()
        }

  @type t :: %OfferBook{
          offers: list(offer)
        }

  defstruct offers: []

  @spec new(t(), price_level_index(), price(), quantity()) ::
          {:ok, t()} | {:error, any()}
  def new(book, price_level_index, price, quantity) do
    new_offer = %{
      price_level_index: price_level_index,
      price: price,
      quantity: quantity
    }

    {:ok, %OfferBook{book | offers: add_offer(book.offers, new_offer)}}
  end

  @spec update(t(), price_level_index(), price(), quantity()) ::
          {:ok, t()} | {:error, any()}
  def update(book, price_level_index, price, quantity) do
    new_offer = %{
      price_level_index: price_level_index,
      price: price,
      quantity: quantity
    }

    case update_offer(book.offers, new_offer) do
      :not_found ->
        {:error, :not_found}

      updated_offers ->
        new_book = %OfferBook{book | offers: updated_offers}
        {:ok, new_book}
    end
  end

  @spec delete(t(), price_level_index()) ::
          {:ok, t()} | {:error, any()}
  def delete(book, price_level_index) do
    {:ok, %OfferBook{book | offers: delete_offers(book.offers, price_level_index)}}
  end

  @spec get(t(), price_level_index()) :: %{price: price(), quantity: quantity()}
  def get(book, price_level_index) do
    case find_offer(book.offers, price_level_index) do
      nil -> %{price: 0.0, quantity: 0}
      offer -> offer
    end
  end

  ##
  ## Private
  ##

  defp add_offer(offers, offer) do
    [offer | offers]
  end

  defp find_offer(offers, price_level_index) do
    Enum.find(offers, fn offer ->
      offer.price_level_index == price_level_index
    end)
  end

  defp update_offer(offers, new_offer) do
    case Enum.find_index(offers, fn offer ->
           offer.price_level_index == new_offer.price_level_index
         end) do
      nil ->
        :not_found

      index ->
        List.replace_at(offers, index, new_offer)
    end
  end

  defp delete_offers(offers, price_level_index) do
    Enum.reject(offers, fn offer ->
      offer.price_level_index == price_level_index
    end)
  end
end
