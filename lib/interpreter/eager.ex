defmodule Interpreter.Eager do
  alias Interpreter.Map, as: Map

  def eval_expr({:atm, atm}, _) do
    {:ok, atm}
  end

  def eval_expr({:var, var}, map) do
    case Map.find(var, map) do
      {_, nil} -> {:error, "Variable '#{inspect(var)}' does not exist"}
      {_, result} -> {:ok, result}
    end
  end

  def eval_expr({:fun, id}, _) do
    {param, seq} = apply(Interpreter.Main, id, [])
    {:ok, {:ctx, param, seq, %{}}}
  end

  def eval_expr({first, rest}, map) do
    case eval_expr(first, map) do
      {:error, msg} ->
        {:error, msg}

      {:ok, first_res} ->
        case eval_expr(rest, map) do
          {:error, msg} ->
            {:error, msg}

          {:ok, rest_res} ->
            {:ok, {first_res, rest_res}}
        end
    end
  end

  def eval_expr({:lambda, param, f_vars, seq}, map) do
    case Map.take(f_vars, map) do
      {:error, msg} ->
        {:error, msg}

      {:ok, ctx} ->
        {:ok, {:ctx, param, seq, ctx}}
    end
  end

  def eval_expr({:apply, exp, args}, map) do
    eval([{:apply, exp, args}], map)
  end

  def eval_match(:_, _, map) do
    {:ok, map}
  end

  def eval_match({:var, var}, exp, map) do
    case Map.find(var, map) do
      {_, ^exp} ->
        {:ok, map}

      {_, nil} ->
        {:ok, Map.add(var, exp, map)}

      {_, result} ->
        {:error,
         "Cannot match '#{inspect(exp)}' onto '#{inspect(var)}', as '#{inspect(var)}' = '#{inspect(result)}'"}
    end
  end

  def eval_match(exp, {:var, var}, map) do
    eval_match({:var, var}, exp, map)
  end

  def eval_match({:atm, atm}, val, map) do
    cond do
      atm == val -> {:ok, map}
      true -> {:error, "Cannot match '#{inspect(val)}' onto '#{inspect(atm)}'"}
    end
  end

  def eval_match(val, {:atm, atm}, map) do
    eval_match({:atm, atm}, val, map)
  end

  def eval_match({p1, p2}, {e1, e2}, map) do
    case eval_match(p1, e1, map) do
      {:error, msg} ->
        {:error, msg}

      {:ok, new_map} ->
        case eval_match(p2, e2, new_map) do
          {:error, msg} ->
            {:error, msg}

          {:ok, rest_map} ->
            {:ok, rest_map}
        end
    end
  end

  def eval_match(e1, e2, _) do
    {:error, "Cannot find any match from '#{inspect(e1)}' to '#{inspect(e2)}'"}
  end

  def extract_vars(:_, list) do
    list
  end

  def extract_vars({:atm, _}, list) do
    list
  end

  def extract_vars({:var, var}, list) do
    [var | list]
  end

  def extract_vars({first, rest}, list) do
    new_list = extract_vars(first, list)
    extract_vars(rest, new_list)
  end

  def eval(exp) do
    eval(exp, %{})
  end

  def eval([], map) do
    map
  end

  def eval([{:match, pat, exp} | rest], map) do
    case eval_expr(exp, map) do
      {:error, msg} ->
        {:error, msg}

      {:ok, data_struct} ->
        clean_map = Map.del(extract_vars(pat, []), map)

        case eval_match(pat, data_struct, clean_map) do
          {:error, msg} ->
            {:error, msg}

          {:ok, new_map} ->
            eval(rest, new_map)
        end
    end
  end

  def eval([{:case, exp, seq}], map) do
    case eval_expr(exp, map) do
      {:error, msg} ->
        {:error, msg}

      {:ok, data_struct} ->
        eval_case(seq, data_struct, map)
    end
  end

  def eval([{:apply, exp, args}], map) do
    IO.inspect(eval_expr(exp, map))
    case eval_expr(exp, map) do
      {:error, msg} ->
        {:error, msg}

      {:ok, {:ctx, params, seq, ctx}} ->
        case eval_ctx({params, args}, map) do
          {:error, msg} ->
            {:error, msg}

          {:ok, new_map} ->
            case eval(seq, Map.merge(ctx, new_map)) do
              {:error, msg} -> {:error, msg}
              {:ok, result} -> result
            end
        end
    end
  end

  def eval([exp], map) do
    case eval_expr(exp, map) do
      {:error, msg} -> {:error, msg}
      {:ok, result} -> result
    end
  end

  def eval_ctx({[], []}, map) do
    {:ok, map}
  end

  def eval_ctx({[param | r1], [arg | r2]}, map) do

    case eval_expr(arg, map) do
      {:error, msg} ->
        {:error, msg}

      {:ok, data_struct} ->
        case eval_match({:var, param}, data_struct, map) do
          {:error, msg} ->
            {:error, msg}

          {:ok, new_map} ->
            eval_ctx({r1, r2}, new_map)
        end
    end
  end

  def eval_case([], _, _) do
    {:error, "No case clause matching"}
  end

  def eval_case([{:clause, pat, seq} | rest], data_struct, map) do
    clean_map = Map.del(extract_vars(pat, []), map)

    case eval_match(pat, data_struct, clean_map) do
      {:error, _} ->
        eval_case(rest, data_struct, map)

      {:ok, new_map} ->
        eval(seq, new_map)
    end
  end
end
