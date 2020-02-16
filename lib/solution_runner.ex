defmodule Solution_runner do
  def all_lazy(p) do
    case Problem.propagate(p) do
      :no_constraints ->
        {:done, Problem.solution(p)}
      :failed ->
        :failed

      {:done, p} ->
        {:done, Problem.solution(p)}

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
    do_split(vlist, p)
  end

  defp do_split([{name, var} | t], p) do
    case Var.is_fixed(var) do
      true ->
        do_split(t, p)

      false ->
        {v1, v2} = Var.split(var)
        p1 = Problem.set_var(p, name, v1)
        p2 = Problem.set_var(p, name, v2)
        {p1, p2}
    end
  end
end
