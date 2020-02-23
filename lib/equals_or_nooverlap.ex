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

    case :setvar.disjoint(a,b) do
      false ->
        case :setvar.unify(a, b) do
          :failed ->
            :failed

          new ->
            {Problem.unifyto(p, lnames, new), []}
        end

      true ->
        case :setvar.is_fixed(a) and :setvar.is_fixed(b) do
          true ->
            {p, []}

          false ->
            # TODO cannot overlap check here
            {p, [fn p -> do_propagate(p, lnames) end]}
        end
    end
  end
end
