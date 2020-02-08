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
    v = Setvar.new_intset(0, :infinity, 0, 10)
    v = Setvar.forbid(5, v)
    v = Setvar.forbid(6, v)
    for i <- [0,1,2,3,4,7,8,9,10] do
      true = Setvar.possible(i, v)
    end
    for i <- [5,6] do
      false = Setvar.possible(i, v)
    end
  end
end
