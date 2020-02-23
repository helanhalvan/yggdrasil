defmodule Golfers do
  @spec start(integer(), integer()) :: any()
  def start(groupsize, groups) do
    total = groups * groupsize

    vars =
      for i <- 1..total do
        v = :setvar.new(groupsize, 1, total)
        :setvar.require(i, v)
      end

    p = Problem.new()
    {p, vars} = Problem.register_vars(p, vars)

    const =
      for i <- vars, j <- vars, i < j do
        EqualsOrNooverlap.new([i, j])
      end

    p = Problem.register_consts(p, const)
    {:done, _, _} = Solution_runner.all_lazy(p)
  end
end
