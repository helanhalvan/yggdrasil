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
end
