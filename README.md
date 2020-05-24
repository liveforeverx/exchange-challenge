# Exchange

Implementation of the coding challenge described in https://www.notion.so/Elixir-Code-Challenge-4604570d02cd400fb8ca82dc2cf38825

The implementation is divided into three modules using the assumptions described below. The main module is `Exchange` which also servers the required API to receive events representing order book updates (`Exchange.send_instruction/2`) and returning the order book when needed (`Exchange.order_book/2`).

The module `Exchange` only orchestrates the communication and keeps the current state in a process (`GenServer`). The business logic is implemented in two separate modules.

The module `Exchange.OfferBook` keeps track of all offers from one side (bid or ask). It provides therefore function to insert, update, delete or retrieve offers. The module `Exchange.OfferMatch` matches offers from both sides (bid and ask) and returns the result of the exchange.

Implementing the business logic in separate module keeps the implementation smaller and allows concentrating on a single functionality. Unit tests for the two business logic modules don't have to deal with asynchronicity which comes into play when working with processes.

## Assumptions

### Independent Sides

Both sides (bid and ask) are treated independently when it comes to the operations triggered by the events (`:new`, `:delete`, and `:update`).

### Matching both Sides

As described in [Order book (trading)](https://en.wikipedia.org/wiki/Order_book_(trading)) the price levels are derived from the price of the bid or the ask.

> When several orders contain the same price, they are referred as a price level, meaning that if, say, a bid comes at that price level, all the sell orders on that price level could potentially fulfill that.

The events send to the exchange have a `price` and a `price_level_index`. Therefore the price level might be the same, even if the price is different. To match the offers from both sides (bid and ask), only the `price_level_index` is used.

This implementation uses the `price_level_index` to match both sides (bid and ask).

### Several Offers with same `price_level_index`

The description of the semantics of the `:new` event is indicating (equal index are shifted up), that it is possible to have offers on one side with the same `price_level_index`.

> Insert new price level. Existing price levels with a greater or equal index are shifted up

But a match between both sides (bid and ask) is done via the price level. Hence only one offer for each side is used per price level. The implementation uses the newest information for a certain price level to find the match. With this and the semantics of the `:delete` event, it has no effect keeping outdated offers.

> Delete a price level. Existing price levels with a higher index will be shifted down

This deletes all offers from one side of a certain price level.

The semantic for the `:new` event are describing "Existing price levels with a greater or equal index are shifted up", but for the `:delete` event only "Existing price levels with a higher index will be shifted down.". With this the behavior of the `:new` event is more like create or update.

To make it more clear I would suggest changing the behavior:

 `:new`->  Insert new price level. If the event is for a price level that has already been created an error must be returned. Existing price levels with a greater index are shifted up.
