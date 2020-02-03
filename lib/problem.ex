defmodule Problem do
  def new do
    %{:vars => %{}, :varc => 0, :varu => %{}, :varuc => 0, :const => []}
  end

  def register_var(p = %{:vars => v, :varc => c}, n) do
    {%{p | :vars => Map.put(v, c, n), :varc => c + 1}, c}
  end

  def register_const(p = %{:const => l}, n) do
    %{p | :const => [n | l]}
  end

  def solve(p = %{:const => c}), do: do_solve(p, c)

  def do_solve(v, c) do
    case propagate(c, v, []) do
      :failed ->
        :failed

      {p, c} ->
        v = :maps.get(:vars, p)
        case Enum.all?(v, fn
          {_key, {:unified, 0}} -> true
          {_key, value} -> Intvar.is_fixed(value) end) do
          true ->
            solution(p)

          false ->
            {v1, v2} = split(v)

            case do_solve(v1, c) do
              :failed -> do_solve(v2, c)
              s -> s
            end
        end
    end
  end

  defp split(p = %{:vars => vars}) do
    vlist = :maps.to_list(vars)
    {a, b} = do_split(vlist, vars)
    {%{p | :vars => a}, %{p | :vars => b}}
  end

  defp do_split([{name, var} | t], vars) do
    case Intvar.is_fixed(var) do
      true ->
        do_split(t, vars)

      false ->
        {min, max} = Intvar.interval(var)
        {%{vars | name => Intvar.new(min)}, %{vars | name => Intvar.new(min + 1, max)}}
    end
  end

  defp solution(p) do
    vars = :maps.get(:vars, p)
    varu = :maps.get(:varu, p)
    :maps.map(fn
      _key, {:unified, a} -> :maps.get(a, varu)
      _key, value -> Intvar.value_if_fixed(value) end, vars)
  end

  def propagate([h | t], v, d) do
    case h.(v) do
      :failed -> :failed
      {:done, v} -> propagate(t, v, d)
      {:not_done, v, h} -> propagate(t, v, [h | d])
    end
  end

  def propagate([], v, d) do
    {v, d}
  end

  def getvar(%{:vars => v, :varu => u}, n) do
    case :maps.get(n, v) do
      {:unified, uname} -> :maps.get(uname, u)
      v -> v
    end
  end

  def setvars(v, new) do
    Map.merge(v, new)
  end

  # This function does not attempt to GC unused variables in varu
  # the amount of garbage is at most size(vars) at the start of solving anyway
  # should be fine
  def unifyto(p = %{:vars => vars, :varu => varu, :varuc => n}, names, new) do
    pointer = {:unified, n}
    vars1 = set_lots(vars, names, pointer)
    %{p | :vars => vars1, :varu => Map.put(varu, n, new), :varuc => n + 1}
  end

  defp set_lots(map, [], _), do: map
  defp set_lots(map, [h|t], v) do
    set_lots(%{map | h => v}, t, v)
  end
end
