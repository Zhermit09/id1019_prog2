defmodule Interpreter.Main do
  alias Interpreter.Map, as: Map
  alias Interpreter.Eager, as: Eager

  def main() do
    IO.inspect("fuck this")

    # IO.inspect(Map.add(:y, 13, Map.add(:x, 12, Map.add(:foo, 42, Map.new()))))
    IO.inspect(Eager.eval_expr({:atm, :a}, %{}))
    IO.inspect(Eager.eval_expr({:var, :x}, Map.add(:x, :a, %{})))
    IO.inspect(Eager.eval_expr({:var, :x}, %{}))
    IO.inspect(Eager.eval_expr({{:var, :x}, {:atm, :b}}, Map.add(:x, :a, %{})))
    IO.inspect(Eager.eval_expr({{:var, :x}, {:atm, :b}}, %{x: :z}))

    IO.puts("\n")

    IO.inspect(Eager.eval_match({:atm, :a}, :a, %{}))
    IO.inspect(Eager.eval_match({:var, :x}, :a, %{}))
    IO.inspect(Eager.eval_match({:var, :x}, :a, Map.add(:x, :a)))
    IO.inspect(Eager.eval_match({:var, :x}, :a, Map.add(:x, :b)))
    IO.inspect(Eager.eval_match({{:var, :x}, {:var, :x}}, {:a, :b}, %{}))
    IO.inspect(Eager.eval_match({{:bruh, :x}, {:var, :x}}, {:a, :b}, %{}))

    IO.puts("\n")

    IO.inspect(
      Eager.eval_match(
        {{:atm, :a}, {{:atm, :a}, {:atm, :b}}},
        {:var, :x},
        %{}
      )
    )

    IO.puts("\n")

    #-------------------------------------------------------------------------

    IO.inspect(
      Eager.eval([
        {:match, {:var, :x}, {:atm, :a}},
        {:match, {:var, :y}, {:atm, :b}},
        {:match, {:var, :x}, {:atm, :c}},
        {{:var, :x}, {:var, :y}}
      ])
    )

    IO.inspect(
      Eager.eval([
        {:match, {:var, :x}, {:atm, :a}},
        {:match, {:var, :y}, {{:var, :x}, {:atm, :b}}},
        {:match, {:_, {:var, :z}}, {:var, :y}},
        {:var, :z}
      ])
    )

    IO.inspect(
      Eager.eval([
        {:match, {:var, :x}, {:atm, :a}},
        {:case, {:var, :x},
         [
           {:clause, {:atm, :b}, [{:atm, :ops}]},
           {:clause, {:atm, :a}, [{:atm, :yes}]}
         ]}
      ])
    )

    IO.inspect(
      Eager.eval([
        {:match, {:var, :x}, {:atm, :a}},
        {:match, {:var, :f}, {:lambda, [:y], [:x], [{{:var, :x}, {:var, :y}}]}},
        {:apply, {:var, :f}, [{:atm, :b}]}
      ])
    )

    IO.inspect(
      Eager.eval([
        {:match, {:var, :z}, {:atm, :c}},
        {:match, {:var, :x}, {:atm, :a}},
        {:match, {:var, :f}, {:lambda, [:y], [:x], [{{:var, :x}, {:var, :y}}]}},
        {:apply, {:var, :f}, [{:var, :z}]}
      ])
    )

    IO.puts("\n")

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
