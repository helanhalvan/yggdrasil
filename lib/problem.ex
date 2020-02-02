defmodule Problem do
  def new do
    %{:vars => %{}, :varc => 0, :const => []}
  end

  def register_var(p = %{:vars => v, :varc => c}, n) do
    {%{p | :vars => Map.put(v, c, n), :varc => c + 1}, c}
  end

  def register_const(p = %{:const => l}, n) do
    %{p | :const => [n | l]}
  end

  def solve(%{:vars => v, :const => c}), do: do_solve(v, c)

  def do_solve(v, c) do
    case propagate(c, v, []) do
      :failed ->
        :failed

      {v, c} ->
        case Enum.all?(v, fn {_key, value} -> Intvar.is_fixed(value) end) do
          true ->
            solution(v)

          false ->
            {v1, v2} = split(v)
            case do_solve(v1, c) do
              :failed -> do_solve(v2, c)
              s -> s
            end
        end
    end
  end

  defp split(vars) do
    vlist = :maps.to_list(vars)
    do_split(vlist, vars)
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

  defp solution(v) do
    :maps.map(fn _key, value -> Intvar.value_if_fixed(value) end, v)
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

  def getvar(v, n) do
    Map.get(v, n)
  end

  def setvars(v, new) do
    Map.merge(v, new)
  end
end
