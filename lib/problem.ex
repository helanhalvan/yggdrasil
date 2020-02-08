defmodule Problem do
  @type const :: (problem -> :failed | {problem, [const]})
  @opaque name :: reference()
  @opaque problem :: %{
            :const => [const],
            :vars => %{optional(name) => Var.variable() | {:unified, name}},
            :varu => %{optional(name) => Var.variable()}
          }

  @spec new :: problem
  def new do
    %{:vars => %{}, :varu => %{}, :const => []}
  end

  @spec register_var(problem, any) :: {problem, name}
  def register_var(p = %{:vars => v}, new) do
    name = make_ref()
    {%{p | :vars => Map.put(v, name, new)}, name}
  end

  @spec register_const(problem, any) :: problem
  def register_const(p = %{:const => l}, n) do
    %{p | :const => [n | l]}
  end

  @spec propagate(problem) ::
          :failed | :no_constraints | {:done, problem} | {:not_done, problem}
  def propagate(%{:const => []}), do: :no_constraints
  def propagate(p = %{:const => c}), do: do_propagate(p, c)

  defp do_propagate(p, c) do
    case propagate(c, p, []) do
      :failed ->
        :failed

      {p, c} ->
        p = %{p | :const => c}

        done =
          case c do
            [] -> :done
            _ -> :not_done
          end

        {done, p}
    end
  end

  defp propagate([h | t], p, d) do
    case h.(p) do
      :failed -> :failed
      {p, []} -> propagate(t, p, d)
      {p, c} -> propagate(t, p, c ++ d)
    end
  end

  defp propagate([], p, d), do: {p, d}

  @spec get_var(problem, name) :: any
  def get_var(%{:vars => v, :varu => u}, n) do
    case :maps.get(n, v) do
      {:unified, uname} -> :maps.get(uname, u)
      v -> v
    end
  end

  @spec get_vars(problem) :: {problem, [{name, any}]}
  def get_vars(p = %{:vars => v, :varu => u}) do
    vlist = Map.to_list(v)
    {_dead, v} = do_get_vars(vlist, u, [])
    # u = Map.drop(u, Map.keys(dead))
    {%{p | :varu => u}, v}
  end

  defp do_get_vars([], u, acc), do: {u, acc}

  defp do_get_vars([{_, {:unified, name}} | t], u, acc) do
    case :maps.get(name, u, :undef) do
      :undef -> do_get_vars(t, u, acc)
      var -> do_get_vars(t, Map.delete(u, name), [{name, var} | acc])
    end
  end

  defp do_get_vars([v | t], u, acc), do: do_get_vars(t, u, [v | acc])

  @spec set_var(problem, name, any) :: problem
  def set_var(p = %{:vars => vars, :varu => varu}, name, value) do
    case :maps.get(name, vars, :undef) do
      {:unified, name} -> %{p | :varu => %{varu | name => value}}
      :undef -> %{p | :varu => %{varu | name => value}}
      _ -> %{p | :vars => %{vars | name => value}}
    end
  end

  # pretty format for a solved problem
  @spec solution(problem) :: %{name => Var.variable()}
  def solution(p) do
    vars = :maps.get(:vars, p)
    varu = :maps.get(:varu, p)

    :maps.map(
      fn
        _key, {:unified, a} -> Intvar.value_if_fixed(:maps.get(a, varu))
        _key, value -> Intvar.value_if_fixed(value)
      end,
      vars
    )
  end

  # This function does not attempt to GC unused variables in varu
  # the amount of garbage is at most size(vars) at the start of solving anyway
  # should be fine
  @spec unifyto(problem, [name], any) :: problem
  def unifyto(p = %{:vars => vars, :varu => varu}, names, new) do
    uname = make_ref()
    pointer = {:unified, uname}
    vars1 = set_lots(vars, names, pointer)
    %{p | :vars => vars1, :varu => Map.put(varu, uname, new)}
  end

  defp set_lots(map, [], _), do: map

  defp set_lots(map, [h | t], v) do
    set_lots(%{map | h => v}, t, v)
  end
end
