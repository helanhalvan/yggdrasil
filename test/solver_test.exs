defmodule SolverTest do
  use ExUnit.Case
  doctest Solver

  test "equals problem" do
    p = Problem.new()
    x = Intvar.new(1, 5)
    y = Intvar.new(1, 10)
    z = Intvar.new(5, 10)
    {p, xn} = Problem.register_var(p, x)
    {p, yn} = Problem.register_var(p, y)
    {p, zn} = Problem.register_var(p, z)
    c = Equals.new([xn, yn, zn])
    p = Problem.register_const(p, c)
    {:done, %{^xn => 5, ^yn => 5, ^zn => 5}} = Solution_runner.all_lazy(p)
  end

  test "equals problem with many solutions" do
    p = Problem.new()
    x = Intvar.new(1, 8)
    y = Intvar.new(1, 10)
    z = Intvar.new(5, 10)
    {p, xn} = Problem.register_var(p, x)
    {p, yn} = Problem.register_var(p, y)
    {p, zn} = Problem.register_var(p, z)
    c = Equals.new([xn, yn, zn])
    p = Problem.register_const(p, c)
    {:done, %{^xn => _, ^yn => _, ^zn => _}} = Solution_runner.all_lazy(p)
  end

  test "setvar forbid" do
    v = Setvar.new_intset(10, 0, 10)
    v = Setvar.forbid(5, v)
    v = Setvar.forbid(6, v)

    for i <- [0, 1, 2, 3, 4, 7, 8, 9, 10] do
      true = Setvar.possible(i, v)
    end

    for i <- [5, 6] do
      false = Setvar.possible(i, v)
    end
  end

  test "social golfers" do
    groupsize = 4
    groups = 1
    total = groups * groupsize

    vars =
      for i <- 1..total do
        v = Setvar.new_intset(4, 1, 8)
        Setvar.require(i, v)
      end

    p = Problem.new()
    {p, vars} = register_all_var(p, vars, [])

    const =
      for i <- vars, j <- vars, i != j do
        EqualsOrNooverlap.new([i, j])
      end

    p = register_all_const(p, const)
    Solution_runner.all_lazy(p)
  end

  defp register_all_var(p, [], names), do: {p, names}

  defp register_all_var(p, [h | t], acc) do
    {p, name} = Problem.register_var(p, h)
    register_all_var(p, t, [name | acc])
  end

  defp register_all_const(p, []), do: p

  defp register_all_const(p, [h | t]) do
    p = Problem.register_const(p, h)
    register_all_const(p, t)
  end
end
