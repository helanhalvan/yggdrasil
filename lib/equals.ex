defmodule Equals do
  def new(x) do
    fn p -> do_propagate(p, x) end
  end

  defp do_propagate(p, [_h]), do: {:done, p}
  defp do_propagate(p, []), do: {:done, p}
  defp do_propagate(p, lnames) do
    lvars =
      for i <- lnames do
        Problem.getvar(p, i)
      end

    case fixed_value(lvars) do
      :undef ->
        # TODO we can still constrain the variables here
        {:not_done, p, new(lnames)}

      v ->
        case Enum.all?(lvars, fn i -> Intvar.isin(i, v) end) do
          true ->
            vs = for key <- lnames, into: %{}, do: {key, Intvar.new(v)}
            p = Problem.setvars(p, vs)
            {:done, p}

          false ->
            :failed
        end
    end
  end

  defp fixed_value([h | t]) do
    case Intvar.value_if_fixed(h) do
      :undef -> fixed_value(t)
      v -> v
    end
  end
end
