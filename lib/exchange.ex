defmodule Exchange do
  use GenServer

  alias Exchange.OfferBook
  alias Exchange.OfferMatch

  ##
  ## API
  ##

  @type event :: %{
          instruction: :new | :update | :delete,
          side: :bid | :ask,
          price_level_index: integer(),
          price: float(),
          quantity: integer()
        }

  @type match :: %{
          bid_price: float(),
          bid_quantity: integer(),
          ask_price: float(),
          ask_quantity: integer()
        }

  @spec start_link :: {:ok, pid} | {:error, any}
  def start_link() do
    GenServer.start_link(__MODULE__, :ok, [])
  end

  @spec stop(pid) :: :ok
  def stop(pid) do
    GenServer.stop(pid)
  end

  @spec send_instruction(
          exchange_pid :: pid(),
          event :: event()
        ) :: :ok | {:error, any()}
  def send_instruction(exchange_pid, event) do
    GenServer.call(exchange_pid, {:send_instruction, event})
  end

  @spec order_book(
          exchange :: pid(),
          book_depth :: integer()
        ) :: list(match())
  def order_book(exchange_pid, depth) do
    GenServer.call(exchange_pid, {:order_book, depth})
  end

  ##
  ## State
  ##

  defmodule State do
    defstruct [
      :bid_offers,
      :ask_offers
    ]
  end

  ##
  ## GenServer callbacks
  ##

  @impl true
  def init(:ok) do
    state = %State{
      bid_offers: %OfferBook{},
      ask_offers: %OfferBook{}
    }

    {:ok, state}
  end

  @impl true
  def handle_call({:send_instruction, %{instruction: :new, side: :bid} = event}, _from, state) do
    with {:ok, new_bid_offers} <-
           OfferBook.new(state.bid_offers, event.price_level_index, event.price, event.quantity) do
      new_state = %State{state | bid_offers: new_bid_offers}
      {:reply, :ok, new_state}
    else
      {:error, reason} ->
        {:reply, {:error, reason}, state}
    end
  end

  @impl true
  def handle_call({:send_instruction, %{instruction: :new, side: :ask} = event}, _from, state) do
    with {:ok, new_ask_offers} <-
           OfferBook.new(state.ask_offers, event.price_level_index, event.price, event.quantity) do
      new_state = %State{state | ask_offers: new_ask_offers}
      {:reply, :ok, new_state}
    else
      {:error, reason} ->
        {:reply, {:error, reason}, state}
    end
  end

  @impl true
  def handle_call({:send_instruction, %{instruction: :update, side: :bid} = event}, _from, state) do
    with {:ok, offers} <-
           OfferBook.update(
             state.bid_offers,
             event.price_level_index,
             event.price,
             event.quantity
           ) do
      new_state = %State{state | bid_offers: offers}
      {:reply, :ok, new_state}
    else
      {:error, reason} ->
        {:reply, {:error, reason}, state}
    end
  end

  @impl true
  def handle_call({:send_instruction, %{instruction: :update, side: :ask} = event}, _from, state) do
    %{price: price, quantity: quantity, price_level_index: price_level_index} = event
    %{ask_offers: ask_offers} = state

    case OfferBook.update(ask_offers, price_level_index, price, quantity) do
      {:ok, offers} ->
        new_state = %State{state | ask_offers: offers}
        {:reply, :ok, new_state}
      {:error, reason} ->
        {:reply, {:error, reason}, state}
    end
  end

  @impl true
  def handle_call({:send_instruction, %{instruction: :delete, side: :bid} = event}, _from, state) do
    with {:ok, new_bid_offers} <- OfferBook.delete(state.bid_offers, event.price_level_index) do
      new_state = %State{
        state
        | bid_offers: new_bid_offers
      }

      {:reply, :ok, new_state}
    else
      {:error, reason} ->
        {:reply, {:error, reason}, state}
    end
  end

  @impl true
  def handle_call({:send_instruction, %{instruction: :delete, side: :ask} = event}, _from, state) do
    with {:ok, new_ask_offers} <- OfferBook.delete(state.ask_offers, event.price_level_index) do
      new_state = %State{
        state
        | ask_offers: new_ask_offers
      }

      {:reply, :ok, new_state}
    else
      {:error, reason} ->
        {:reply, {:error, reason}, state}
    end
  end

  @impl true
  def handle_call({:order_book, depth}, _from, state) do
    order_book = OfferMatch.match(state.ask_offers, state.bid_offers, depth)
    {:reply, order_book, state}
  end
end
