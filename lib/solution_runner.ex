defmodule Solution_runner do
  def all_lazy(p) do
    case Problem.propagate(p) do
      :no_constraints ->
        :todo
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

  defp split(p) do
    {p, vlist} = Problem.get_vars(p)
    {a, b} = do_split(vlist, p)
    {%{p | :vars => a}, %{p | :vars => b}}
  end

  defp do_split([{name, var} | t], p) do
    case Intvar.is_fixed(var) do
      true ->
        do_split(t, p)

      false ->
        {min, max} = Intvar.interval(var)
        p1 = Problem.set_var(p, name, Intvar.new(min))
        p2 = Problem.set_var(p, name, Intvar.new(min + 1, max))
        {p1, p2}
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
