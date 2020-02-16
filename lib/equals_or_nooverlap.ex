defmodule EqualsOrNooverlap do
  # from var.ex
  @type variable :: tuple()
  @spec new([variable()]) :: (any -> :failed | {:done, any})
  def new(x) do
    fn p -> do_propagate(p, x) end
  end

  defp do_propagate(p, lnames) do
    [a, b] =
      for i <- lnames do
        Problem.get_var(p, i)
      end
    case MapSet.disjoint?(Setvar.required(a), Setvar.required(b)) do
      false ->
        case Setvar.unify(a, b) do
          :failed -> :failed
          new -> {Problem.unifyto(p, lnames, new), []}
        end

      true ->
        {p, [fn p -> do_propagate(p, lnames) end]}
    end
  end
end
