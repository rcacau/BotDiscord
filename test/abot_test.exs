defmodule AbotTest do
  use ExUnit.Case
  doctest Abot

  test "greets the world" do
    assert Abot.hello() == :world
  end
end
