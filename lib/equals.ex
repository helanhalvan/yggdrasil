defmodule Equals do
  @type variable :: tuple() # from var.ex
  @spec new([variable()]) :: (any -> :failed | {:done, any})
  def new(x) do
    fn p -> do_propagate(p, x) end
  end

  defp do_propagate(p, [_h]), do: {:done, p}
  defp do_propagate(p, []), do: {:done, p}

  defp do_propagate(p, lnames) do
    [h | t] =
      for i <- lnames do
        Problem.getvar(p, i)
      end

    case do_unify(h, t) do
      :failed ->
        :failed

      v ->
        p = Problem.unifyto(p, lnames, v)
        {:done, p}
    end
  end

  defp do_unify(o, []), do: o

  defp do_unify(o, [h | t]) do
    case Var.unify(o, h) do
      :failed -> :failed
      v -> do_unify(v, t)
    end
  end
end
