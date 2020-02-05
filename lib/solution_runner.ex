defmodule Solution_runner do
  def all_lazy(p) do
    case Problem.propagate(p) do
      :failed ->
        :failed

      {:done, p} ->
        {:done, solution(p)}

      {:not_done, p} ->
        {a, b} = split(p)

        case all_lazy(a) do
          :failed -> all_lazy(b)
          {:done, p} -> {p, fn -> all_lazy(b) end}
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

    :maps.map(
      fn
        _key, {:unified, a} -> Intvar.value_if_fixed(:maps.get(a, varu))
        _key, value -> Intvar.value_if_fixed(value)
      end,
      vars
    )
  end
end
