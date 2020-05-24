defmodule ExchangeTest do
  use ExUnit.Case

  test "starting and stopping the exchange" do
    assert {:ok, exchange_pid} = Exchange.start_link()
    assert :ok = Exchange.stop(exchange_pid)
  end

  test "the example given in the challenge" do
    assert {:ok, exchange_pid} = Exchange.start_link()

    assert Exchange.send_instruction(exchange_pid, %{
             instruction: :new,
             side: :bid,
             price_level_index: 1,
             price: 50.0,
             quantity: 30
           }) == :ok

    assert Exchange.send_instruction(exchange_pid, %{
             instruction: :new,
             side: :bid,
             price_level_index: 2,
             price: 40.0,
             quantity: 40
           }) == :ok

    assert Exchange.send_instruction(exchange_pid, %{
             instruction: :new,
             side: :ask,
             price_level_index: 1,
             price: 60.0,
             quantity: 10
           }) == :ok

    assert Exchange.send_instruction(exchange_pid, %{
             instruction: :new,
             side: :ask,
             price_level_index: 2,
             price: 70.0,
             quantity: 10
           }) == :ok

    assert Exchange.send_instruction(exchange_pid, %{
             instruction: :update,
             side: :ask,
             price_level_index: 2,
             price: 70.0,
             quantity: 20
           }) == :ok

    assert Exchange.send_instruction(exchange_pid, %{
             instruction: :update,
             side: :bid,
             price_level_index: 1,
             price: 50.0,
             quantity: 40
           }) == :ok

    assert Exchange.order_book(exchange_pid, 2) == [
             %{ask_price: 60.0, ask_quantity: 10, bid_price: 50.0, bid_quantity: 40},
             %{ask_price: 70.0, ask_quantity: 20, bid_price: 40.0, bid_quantity: 40}
           ]
  end
end
