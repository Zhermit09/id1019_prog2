defmodule Interpreter.Main do
  alias Interpreter.Map, as: Map
  alias Interpreter.Eager, as: Eager

  def main() do

    IO.inspect(
      Eager.eval([
        {:match, {:var, :x}, {{:atm, :a}, {{:atm, :b}, {:atm, []}}}},
        {:match, {:var, :y}, {{:atm, :c}, {{:atm, :d}, {:atm, []}}}},
        {:apply, {:fun, :append}, [{:var, :x}, {:var, :y}]}
      ])
    )
  end

  def append() do
    {[:x, :y],
     [
       {:case, {:var, :x},
        [
          {:clause, {:atm, []},
           [
             {:var, :y}
           ]},
          {:clause, {{:var, :hd}, {:var, :tl}},
           [
             {{:var, :hd}, {:apply, {:fun, :append}, [{:var, :tl}, {:var, :y}]}}
           ]}
        ]}
     ]}
  end
end
